variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to create. Must be globally unique"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must start and end with a lowercase letter or number, and can only contain lowercase letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be between 3 and 63 characters long."
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region where the S3 bucket will be created"
  default     = "ca-central-1"
}

variable "block_public_access" {
  type        = bool
  description = "Enable all public access block settings for the S3 bucket"
  default     = true
}

variable "enable_encryption" {
  type        = bool
  description = "Enable server-side encryption for the S3 bucket"
  default     = true
}

variable "enforce_ssl" {
  type        = bool
  description = "Enforce SSL/TLS for all requests to the S3 bucket using bucket policy"
  default     = true
}

variable "enable_cloudtrail" {
  type        = bool
  description = "Enable CloudTrail logging for S3 data events. Required for AWS Security Hub S3-22 compliance (object-level logging for read/write events)"
  default     = true
}

variable "cloudtrail_name" {
  type        = string
  description = "Name of the CloudTrail trail"
  default     = ""
}

variable "cloudtrail_s3_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for CloudTrail logs. Must be a separate dedicated logging bucket (not the bucket being monitored). Required when enable_cloudtrail is true for AWS Security Hub S3-22 compliance"
  default     = "s3-22-logging-bucket"

  validation {
    condition     = var.cloudtrail_s3_bucket_name != ""
    error_message = "cloudtrail_s3_bucket_name is required when enable_cloudtrail is true. CloudTrail logs must be stored in a separate dedicated logging bucket for S3-22 compliance."
  }

  validation {
    condition     = var.cloudtrail_s3_bucket_name == "" || var.cloudtrail_s3_bucket_name != var.bucket_name
    error_message = "cloudtrail_s3_bucket_name must be different from bucket_name. CloudTrail logs cannot be stored in the same bucket being monitored."
  }
}

variable "cloudtrail_s3_key_prefix" {
  type        = string
  description = "S3 key prefix for CloudTrail logs"
  default     = "cloudtrail/"
}

variable "cloudtrail_cloudwatch_log_group_name" {
  type        = string
  description = "Name of the CloudWatch Log Group for CloudTrail logs"
  default     = ""
}

variable "cloudtrail_log_retention_days" {
  type        = number
  description = "Number of days to retain CloudTrail logs in CloudWatch Logs"
  default     = 90
}

variable "cloudtrail_kms_key_alias" {
  type        = string
  description = "Alias for the KMS key used to encrypt CloudTrail logs"
  default     = ""
}

variable "enable_mfa_delete" {
  type        = bool
  description = "Enable MFA delete for the S3 bucket versioning configuration. Required for AWS Security Hub S3-20 compliance. Note: MFA delete is always enabled to meet compliance requirements"
  default     = true

  validation {
    condition     = var.enable_mfa_delete == true
    error_message = "MFA delete must be enabled for AWS Security Hub S3-20 compliance. Versioning with MFA delete is mandatory for this module."
  }
}

variable "force_destroy" {
  type        = bool
  description = "Allow destruction of the bucket even if it contains objects"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the S3 bucket"
  default     = {}
}
