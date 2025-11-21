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
  description = "Enforce SSL/TLS for all requests to the S3 bucket using bucket policy. Required for AWS Security Hub S3-5 compliance. Note: SSL/TLS enforcement is always enabled to meet compliance requirements"
  default     = true

  validation {
    condition     = var.enforce_ssl == true
    error_message = "SSL/TLS enforcement must be enabled for AWS Security Hub S3-5 compliance. All requests to S3 buckets must use SSL."
  }
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
