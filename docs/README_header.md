# AWS S3 Bucket Terraform Module

This Terraform module provisions and manages an AWS S3 bucket with security best practices enabled by default.

The module provides a simple, secure way to create S3 buckets with optional versioning, server-side encryption, and public access blocking.

## Permissions

### AWS Permissions

To provision resources, the AWS provider requires credentials with appropriate IAM permissions. The following permissions are required:

**S3 Permissions:**
* `s3:CreateBucket` - Create S3 buckets
* `s3:DeleteBucket` - Delete S3 buckets
* `s3:PutBucketVersioning` - Configure bucket versioning
* `s3:PutEncryptionConfiguration` - Configure server-side encryption
* `s3:PutBucketPublicAccessBlock` - Configure public access block settings
* `s3:PutBucketPolicy` - Configure bucket policies
* `s3:GetBucketPolicy` - Read bucket policies
* `s3:GetBucketAcl` - Read bucket ACL (required by CloudTrail)
* `s3:GetBucketVersioning` - Read bucket versioning configuration
* `s3:GetEncryptionConfiguration` - Read encryption configuration
* `s3:GetBucketPublicAccessBlock` - Read public access block settings
* `s3:ListBucket` - List bucket contents
* `s3:PutBucketTagging` - Apply tags to buckets
* `s3:GetBucketTagging` - Read bucket tags

**CloudTrail Permissions (when CloudTrail logging is enabled):**
* `cloudtrail:CreateTrail` - Create CloudTrail trails
* `cloudtrail:DeleteTrail` - Delete CloudTrail trails
* `cloudtrail:UpdateTrail` - Update CloudTrail trails
* `cloudtrail:PutEventSelectors` - Configure event selectors
* `cloudtrail:GetTrail` - Read trail configuration
* `cloudtrail:GetEventSelectors` - Read event selectors
* `cloudtrail:StartLogging` - Start CloudTrail logging
* `cloudtrail:StopLogging` - Stop CloudTrail logging

**CloudWatch Logs Permissions (when CloudTrail logging is enabled):**
* `logs:CreateLogGroup` - Create CloudWatch Log Groups
* `logs:DeleteLogGroup` - Delete CloudWatch Log Groups
* `logs:PutRetentionPolicy` - Configure log retention policies
* `logs:CreateLogStream` - Create log streams (used by CloudTrail)
* `logs:PutLogEvents` - Write log events (used by CloudTrail)
* `logs:DescribeLogGroups` - Read log group configuration

**KMS Permissions (when CloudTrail logging is enabled):**
* `kms:CreateKey` - Create KMS keys for CloudTrail encryption
* `kms:CreateAlias` - Create KMS key aliases
* `kms:DeleteAlias` - Delete KMS key aliases
* `kms:DescribeKey` - Read KMS key information
* `kms:GetKeyPolicy` - Read KMS key policy
* `kms:PutKeyPolicy` - Configure KMS key policy
* `kms:EnableKeyRotation` - Enable automatic key rotation
* `kms:DisableKeyRotation` - Disable automatic key rotation
* `kms:ScheduleKeyDeletion` - Schedule KMS key deletion
* `kms:GenerateDataKey` - Generate data keys (used by CloudTrail)
* `kms:Decrypt` - Decrypt data (used by CloudTrail)
* `kms:ListAliases` - List KMS key aliases
* `kms:TagResource` - Apply tags to KMS keys
* `kms:UntagResource` - Remove tags from KMS keys

**IAM Permissions (when CloudTrail logging is enabled):**
* `iam:CreateRole` - Create IAM roles for CloudTrail CloudWatch Logs
* `iam:DeleteRole` - Delete IAM roles
* `iam:GetRole` - Read IAM role configuration
* `iam:PutRolePolicy` - Attach inline policies to roles
* `iam:DeleteRolePolicy` - Delete inline policies from roles
* `iam:GetRolePolicy` - Read inline role policies

## Authentication

### AWS Authentication

The AWS provider supports multiple authentication methods:

* **Environment Variables**: Set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
* **Shared Credentials File**: Use `~/.aws/credentials` with profile configuration
* **IAM Role**: When running on AWS services (EC2, ECS, Lambda), use IAM roles
* **EC2 Instance Metadata**: Automatically available on EC2 instances with IAM roles

The recommended approach is to use IAM roles when running in AWS, or shared credentials files for local development.

## Features

This module provides the following key features:

* **Secure by Default**: All security best practices enabled out of the box
  * Server-side encryption with AES256 enabled by default
  * SSL/TLS enforcement for all requests enabled by default
  * Public access blocking enabled by default
  * Bucket versioning enabled by default
  * MFA delete support enabled by default for versioning protection
* **CloudTrail Logging**: AWS CloudTrail integration for S3 data event logging and audit (enabled by default)
  * Object-level logging for read/write events (AWS Security Hub S3-22 compliant)
  * CloudWatch Logs integration for real-time monitoring (AWS Security Hub CloudTrail-5 compliant)
  * KMS encryption for CloudTrail logs (AWS Security Hub CloudTrail-2 compliant)
  * Automatic key rotation enabled for KMS keys
  * **Note**: CloudTrail logging should remain enabled for AWS Security Hub S3-22 compliance
* **Flexible Configuration**: All security features can be optionally disabled (Note: Disabling CloudTrail will cause S3-22 control failure)
* **Bucket Name Validation**: Input validation ensures bucket names meet AWS requirements
* **Tagging Support**: Apply custom tags and automatic management tags
* **Conditional Resources**: Uses count meta-argument for optional feature management
* **Latest Provider**: Uses AWS provider version 6.21.0

## Resources Provisioned

This module provisions the following AWS resources:

* **aws_s3_bucket** - Main S3 bucket resource
* **aws_s3_bucket_versioning** - Bucket versioning configuration with MFA delete support (optional, enabled by default)
* **aws_s3_bucket_server_side_encryption_configuration** - Server-side encryption with AES256 (optional, enabled by default)
* **aws_s3_bucket_public_access_block** - Public access block settings (optional, enabled by default)
* **aws_s3_bucket_policy** - Bucket policy to enforce SSL/TLS and CloudTrail permissions (conditional)
* **aws_cloudtrail** - CloudTrail trail for S3 data event logging (optional, disabled by default)
* **aws_cloudwatch_log_group** - CloudWatch Log Group for CloudTrail logs with 90-day retention (optional, created when CloudTrail is enabled)
* **aws_kms_key** - KMS key for CloudTrail log encryption with automatic rotation (optional, created when CloudTrail is enabled)
* **aws_kms_alias** - KMS key alias for easy reference (optional, created when CloudTrail is enabled)
* **aws_iam_role** - IAM role for CloudTrail to write to CloudWatch Logs (optional, created when CloudTrail is enabled)
* **aws_iam_role_policy** - IAM policy granting CloudTrail permissions to create log streams and put log events (optional, created when CloudTrail is enabled)
