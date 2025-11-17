# S3 Bucket Resource
resource "aws_s3_bucket" "main" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(
    var.tags,
    {
      Name = var.bucket_name
    }
  )
}

# S3 Bucket Versioning Configuration
resource "aws_s3_bucket_versioning" "main" {
  count = var.enable_versioning ? 1 : 0

  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status     = "Enabled"
    mfa_delete = var.enable_mfa_delete ? "Enabled" : "Disabled"
  }
}

# S3 Bucket Server-Side Encryption Configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count = var.enable_encryption ? 1 : 0

  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block Configuration
resource "aws_s3_bucket_public_access_block" "main" {
  count = var.block_public_access ? 1 : 0

  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Policy to Enforce SSL/TLS and Allow CloudTrail
data "aws_caller_identity" "current" {
  count = var.enforce_ssl || var.enable_cloudtrail ? 1 : 0
}

data "aws_partition" "current" {
  count = var.enable_cloudtrail ? 1 : 0
}

data "aws_region" "current" {
  count = var.enable_cloudtrail ? 1 : 0
}

data "aws_iam_policy_document" "bucket_policy" {
  count = var.enforce_ssl || var.enable_cloudtrail ? 1 : 0

  # Deny insecure transport
  dynamic "statement" {
    for_each = var.enforce_ssl ? [1] : []
    content {
      sid    = "DenyInsecureTransport"
      effect = "Deny"

      principals {
        type        = "*"
        identifiers = ["*"]
      }

      actions = [
        "s3:*"
      ]

      resources = [
        aws_s3_bucket.main.arn,
        "${aws_s3_bucket.main.arn}/*"
      ]

      condition {
        test     = "Bool"
        variable = "aws:SecureTransport"
        values   = ["false"]
      }
    }
  }

  # Allow CloudTrail to check bucket ACL
  dynamic "statement" {
    for_each = var.enable_cloudtrail ? [1] : []
    content {
      sid    = "AWSCloudTrailAclCheck"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["cloudtrail.amazonaws.com"]
      }

      actions   = ["s3:GetBucketAcl"]
      resources = [aws_s3_bucket.main.arn]

      condition {
        test     = "StringEquals"
        variable = "aws:SourceArn"
        values   = ["arn:${data.aws_partition.current[0].partition}:cloudtrail:${data.aws_region.current[0].name}:${data.aws_caller_identity.current[0].account_id}:trail/${var.cloudtrail_name != "" ? var.cloudtrail_name : "${var.bucket_name}-trail"}"]
      }
    }
  }

  # Allow CloudTrail to write logs
  dynamic "statement" {
    for_each = var.enable_cloudtrail ? [1] : []
    content {
      sid    = "AWSCloudTrailWrite"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["cloudtrail.amazonaws.com"]
      }

      actions   = ["s3:PutObject"]
      resources = ["${aws_s3_bucket.main.arn}/*"]

      condition {
        test     = "StringEquals"
        variable = "s3:x-amz-acl"
        values   = ["bucket-owner-full-control"]
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceArn"
        values   = ["arn:${data.aws_partition.current[0].partition}:cloudtrail:${data.aws_region.current[0].name}:${data.aws_caller_identity.current[0].account_id}:trail/${var.cloudtrail_name != "" ? var.cloudtrail_name : "${var.bucket_name}-trail"}"]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  count = var.enforce_ssl || var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.bucket_policy[0].json
}

# CloudTrail for S3 Data Events
resource "aws_cloudtrail" "main" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = var.cloudtrail_name != "" ? var.cloudtrail_name : "${var.bucket_name}-trail"
  s3_bucket_name                = var.cloudtrail_s3_bucket_name != "" ? var.cloudtrail_s3_bucket_name : aws_s3_bucket.main.id
  s3_key_prefix                 = var.cloudtrail_s3_key_prefix
  include_global_service_events = false
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch[0].arn
  kms_key_id                    = aws_kms_key.cloudtrail[0].arn

  event_selector {
    read_write_type           = "All"
    include_management_events = false

    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.main.arn}/"]
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.cloudtrail_name != "" ? var.cloudtrail_name : "${var.bucket_name}-trail"
    }
  )

  depends_on = [aws_s3_bucket_policy.main]
}

# KMS Key for CloudTrail Log Encryption
data "aws_iam_policy_document" "cloudtrail_kms_policy" {
  count = var.enable_cloudtrail ? 1 : 0

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current[0].partition}:iam::${data.aws_caller_identity.current[0].account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "kms:GenerateDataKey*",
      "kms:DecryptDataKey"
    ]

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${data.aws_partition.current[0].partition}:cloudtrail:${data.aws_region.current[0].name}:${data.aws_caller_identity.current[0].account_id}:trail/*"]
    }
  }

  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current[0].account_id]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${data.aws_partition.current[0].partition}:cloudtrail:${data.aws_region.current[0].name}:${data.aws_caller_identity.current[0].account_id}:trail/*"]
    }
  }

  statement {
    sid    = "Allow alias creation during setup"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["kms:CreateAlias"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current[0].account_id]
    }
  }
}

resource "aws_kms_key" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  description             = "KMS key for CloudTrail log encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.cloudtrail_kms_policy[0].json

  tags = merge(
    var.tags,
    {
      Name = var.cloudtrail_kms_key_alias != "" ? var.cloudtrail_kms_key_alias : "cloudtrail-${var.cloudtrail_name != "" ? var.cloudtrail_name : "${var.bucket_name}-trail"}"
    }
  )
}

resource "aws_kms_alias" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  name          = var.cloudtrail_kms_key_alias != "" ? "alias/${var.cloudtrail_kms_key_alias}" : "alias/cloudtrail-${var.cloudtrail_name != "" ? var.cloudtrail_name : "${var.bucket_name}-trail"}"
  target_key_id = aws_kms_key.cloudtrail[0].key_id
}

# CloudWatch Log Group for CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  name              = var.cloudtrail_cloudwatch_log_group_name != "" ? var.cloudtrail_cloudwatch_log_group_name : "/aws/cloudtrail/${var.cloudtrail_name != "" ? var.cloudtrail_name : "${var.bucket_name}-trail"}"
  retention_in_days = var.cloudtrail_log_retention_days

  tags = merge(
    var.tags,
    {
      Name = var.cloudtrail_cloudwatch_log_group_name != "" ? var.cloudtrail_cloudwatch_log_group_name : "/aws/cloudtrail/${var.cloudtrail_name != "" ? var.cloudtrail_name : "${var.bucket_name}-trail"}"
    }
  )
}

# IAM Role for CloudTrail to write to CloudWatch Logs
data "aws_iam_policy_document" "cloudtrail_assume_role" {
  count = var.enable_cloudtrail ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudtrail_cloudwatch" {
  count = var.enable_cloudtrail ? 1 : 0

  name               = var.cloudtrail_name != "" ? "${var.cloudtrail_name}-cloudwatch-role" : "${var.bucket_name}-trail-cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role[0].json

  tags = merge(
    var.tags,
    {
      Name = var.cloudtrail_name != "" ? "${var.cloudtrail_name}-cloudwatch-role" : "${var.bucket_name}-trail-cloudwatch-role"
    }
  )
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_policy" {
  count = var.enable_cloudtrail ? 1 : 0

  statement {
    sid    = "CreateLogStream"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["${aws_cloudwatch_log_group.cloudtrail[0].arn}:*"]
  }
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  count = var.enable_cloudtrail ? 1 : 0

  name   = "cloudtrail-cloudwatch-logs"
  role   = aws_iam_role.cloudtrail_cloudwatch[0].id
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_policy[0].json
}

