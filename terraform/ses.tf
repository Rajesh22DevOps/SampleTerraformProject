# #
# # S3 bucket for receiving bounces
# #

# resource "aws_s3_bucket" "bucket1" {
#   bucket = "test-active-s3-bucket"
# }

# resource "aws_s3_bucket_policy" "bucket_policy" {
#   bucket = aws_s3_bucket.bucket1.id

#   policy = <<POLICY
# # {
# #     "Version": "2012-10-17",
# #     "Statement": [
# #         {
# #             "Sid": "AllowSESPuts",
# #             "Effect": "Allow",
# #             "Principal": {
# #                 "Service": "ses.amazonaws.com"
# #             },
# #            "Action": [
# #                 "s3:PutObject",
# #                 "s3:PutObjectAcl"
# #             ],
# #             "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket1.arn}/*",
# #             "Condition": {
# #                 "StringEquals": {
# #                     "aws:Referer": "${data.aws_caller_identity.current.account_id}"
# #                 }
# #             }
# #         }
# #     ]
# # }
# {
#   "Version":"2012-10-17",
#   "Statement":[
#     {
#       "Sid":"AllowSESPuts",
#       "Effect":"Allow",
#       "Principal":{
#         "Service":"ses.amazonaws.com"
#       },
#       "Action":"s3:PutObject",
#       "Resource":"arn:aws:s3:::myBucket/*",
#       "Condition":{
#         "StringEquals":{
#           "AWS:SourceAccount":"111122223333",
#           "AWS:SourceArn": "arn:aws:ses:region:111122223333:receipt-rule-set/${aws_ses_receipt_rule_set.ses_receipt_rule_set.rule_set_name
# }:receipt-rule/${aws_ses_receipt_rule.ses_receipt_rule.rule_set_name}"
#         }
#       }
#     }
#   ]
# }
# POLICY
# }


# resource "aws_ses_email_identity" "email" {
#   email = "test@example.com"
# }

# resource "aws_ses_receipt_rule_set" "ses_receipt_rule_set" {
#   rule_set_name = "primary"
# }

# resource "aws_ses_active_receipt_rule_set" "ses_receipt_rule_set" {
#   rule_set_name = aws_ses_receipt_rule_set.ses_receipt_rule_set.rule_set_name
# }

# resource "aws_ses_receipt_rule" "ses_receipt_rule" {
#   name          = "test-rule-name"
#   rule_set_name = aws_ses_receipt_rule_set.ses_receipt_rule_set.rule_set_name
#   enabled       = true
#   scan_enabled  = false

#   s3_action {
#     position    = 1
#     bucket_name = aws_s3_bucket.bucket1.id
#   }

# }


# Use an existing bucket
# data "aws_s3_bucket" "mailbox" {
#   bucket = var.aws_s3_bucket_mailbox
# }

resource "aws_s3_bucket" "bucket1" {
  bucket = "test-active-s3-bucket"
}

resource "aws_ses_domain_identity" "default" {
  count  = var.enable_domain ? 1 : 0
  domain = "example.com"
}

data "aws_iam_policy_document" "document" {
  statement {
    actions   = ["SES:SendEmail", "SES:SendRawEmail"]
    resources = [aws_ses_domain_identity.default[0].arn]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}

# Enable Put from SES to S3 bucket
resource "aws_s3_bucket_policy" "mailbox" {
  bucket = aws_s3_bucket.bucket1.id
  policy = data.aws_iam_policy_document.mailbox.json
}

data "aws_iam_policy_document" "mailbox" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    
    resources = ["${aws_s3_bucket.bucket1.arn}/*"]

    condition {
      test     = "Null"
      values   = ["false"]
      variable = "s3:x-amz-server-side-encryption"
    }

    condition {
      test     = "StringNotEquals"
      values   = [local.sse_algorithm]
      variable = "s3:x-amz-server-side-encryption"
    }
  }
}

# Create a new rule set
resource "aws_ses_receipt_rule_set" "main" {
  #   provider      = "aws.ses"
  rule_set_name = "s3"
}

resource "aws_ses_receipt_rule" "main" {
  #   provider      = "aws.ses"
  name          = "s3"
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
#   recipients    = ["${var.receiver_address}"]
  enabled       = true
  scan_enabled  = true
  tls_policy = "Require"
  s3_action {
    bucket_name       = aws_s3_bucket.bucket1.id
    # object_key_prefix = "mailbox/${var.receiver_address}"
    position          = 1
  }
}

# Activate rule set
resource "aws_ses_active_receipt_rule_set" "main" {
  #   provider      = "aws.ses"
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
}
