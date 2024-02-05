provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = "us-east-1"
}
data "aws_caller_identity" "current" {}
data "aws_canonical_user_id" "this" {}

locals {
  create_bucket = var.create_bucket && var.putin_khuylo
  sse_s3_algorithm  = "AES256"
  sse_kms_algorithm = "aws:kms"

  sse_algorithm     = var.kms_key_arn == "" ? local.sse_s3_algorithm : local.sse_kms_algorithm
  kms_master_key_id = var.kms_key_arn == "" ? null : var.kms_key_arn

}

resource "aws_s3_bucket" "this" {
  count = local.create_bucket ? 1 : 0

  bucket = var.bucket
  tags   = var.tags

}

resource "aws_sqs_queue" "queue" {
  name = "s3-event-notification-queue"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:s3-event-notification-queue",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.bucket1.arn}" }
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket1.id

  queue {
    queue_arn = aws_sqs_queue.queue.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypted_bucket" {
  bucket = aws_s3_bucket.bucket1.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.kms_master_key_id
      sse_algorithm     = local.sse_algorithm
    }
    bucket_key_enabled = var.enable_bucket_key
  }
}