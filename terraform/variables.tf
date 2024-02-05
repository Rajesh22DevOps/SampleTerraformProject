variable "access_key" {
  description = "Access key of AWS IAM User with the required permissions for SQS Queue creation and deletion"
}
variable "secret_key" {
  description = "Secret key of AWS IAM user with the required permissions for SQS Queue creation and deletion"
}


variable "sqs_name" {
  description = "Name of the sqs queue to be created. You can assign any unique name for the Queue"
  default     = "my-first-sqs"
}

variable "create_bucket" {
  description = "Controls if S3 bucket should be created"
  type        = bool
  default     = true
}

variable "bucket" {
  description = "(Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = null
}

variable "bucket_prefix" {
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
  type        = string
  default     = null
}

variable "acl" {
  description = "(Optional) The canned ACL to apply. Conflicts with `grant`"
  type        = string
  default     = null
}

variable "policy" {
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}


variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}


variable "putin_khuylo" {
  description = "Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo!"
  type        = bool
  default     = true
}



variable "aws_s3_bucket_mailbox" {
  type    = string
  default = "Destination Bucket name"
}
variable "receiver_address" {
  type    = string
  default = "Receive mail address"
}

variable "kms_key_arn" {
  description = "If provided, \"aws:kms\" encryption will be enforced using the KMS key with the provided ARN. By default, \"AES-256\" encryption is used."
  type = string
  default = ""
}   

variable "enable_bucket_key" {
  description = "Whether or not to use an Amazon S3 Bucket Key for SSE-KMS. Defaults to `false`."
  type = bool
  default = false
}

variable "enable_domain" {
  type        = bool
  default     = true
  description = "Control whether or not to enable domain."
}
