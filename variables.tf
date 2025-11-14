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
  default     = "us-east-1"
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

variable "enable_logging" {
  type        = bool
  description = "Enable server access logging for the S3 bucket"
  default     = false
}

variable "enable_mfa_delete" {
  type        = bool
  description = "Enable MFA delete for the S3 bucket versioning configuration. Versioning must be enabled"
  default     = false
}

variable "enable_versioning" {
  type        = bool
  description = "Enable versioning for the S3 bucket"
  default     = true
}

variable "force_destroy" {
  type        = bool
  description = "Allow destruction of the bucket even if it contains objects"
  default     = false
}

variable "logging_target_bucket" {
  type        = string
  description = "Name of the target bucket for access logs. If not provided and logging is enabled, logs will be stored in the same bucket"
  default     = ""
}

variable "logging_target_prefix" {
  type        = string
  description = "Prefix for all log object keys"
  default     = "logs/"
}

variable "project_name" {
  type        = string
  description = "Name of the project for tagging resources"
  default     = "s3-bucket-project"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the S3 bucket"
  default     = {}
}
