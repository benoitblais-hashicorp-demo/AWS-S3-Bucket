<!-- BEGIN_TF_DOCS -->
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
  * Bucket versioning **always enabled** (AWS Security Hub S3-20 compliant)
  * MFA delete **always enabled** for versioning protection (AWS Security Hub S3-20 compliant - cannot be disabled)
* **CloudTrail Logging**: AWS CloudTrail integration for S3 data event logging and audit (enabled by default)
  * Object-level logging for read/write events (AWS Security Hub S3-22 compliant)
  * CloudTrail logs stored in a separate dedicated logging bucket (required for compliance)
  * CloudWatch Logs integration for real-time monitoring (AWS Security Hub CloudTrail-5 compliant)
  * KMS encryption for CloudTrail logs (AWS Security Hub CloudTrail-2 compliant)
  * Automatic key rotation enabled for KMS keys
  * **Note**: CloudTrail logging requires a separate S3 bucket for logs; cannot log to the same bucket being monitored
* **Flexible Configuration**: Some security features can be optionally disabled (Note: Versioning with MFA delete is mandatory for S3-20 compliance; Disabling CloudTrail will cause S3-22 control failure)
* **Bucket Name Validation**: Input validation ensures bucket names meet AWS requirements
* **Tagging Support**: Apply custom tags and automatic management tags
* **Conditional Resources**: Uses count meta-argument for optional feature management
* **Latest Provider**: Uses AWS provider version 6.21.0

## Resources Provisioned

This module provisions the following AWS resources:

* **aws\_s3\_bucket** - Main S3 bucket resource
* **aws\_s3\_bucket\_versioning** - Bucket versioning with MFA delete (always enabled for AWS Security Hub S3-20 compliance)
* **aws\_s3\_bucket\_server\_side\_encryption\_configuration** - Server-side encryption with AES256 (optional, enabled by default)
* **aws\_s3\_bucket\_public\_access\_block** - Public access block settings (optional, enabled by default)
* **aws\_s3\_bucket\_policy** - Bucket policy to enforce SSL/TLS (conditional)
* **aws\_cloudtrail** - CloudTrail trail for S3 data event logging (optional, enabled by default)
* **aws\_cloudwatch\_log\_group** - CloudWatch Log Group for CloudTrail logs with 90-day retention (optional, created when CloudTrail is enabled)
* **aws\_kms\_key** - KMS key for CloudTrail log encryption with automatic rotation (optional, created when CloudTrail is enabled)
* **aws\_kms\_alias** - KMS key alias for easy reference (optional, created when CloudTrail is enabled)
* **aws\_iam\_role** - IAM role for CloudTrail to write to CloudWatch Logs (optional, created when CloudTrail is enabled)
* **aws\_iam\_role\_policy** - IAM policy granting CloudTrail permissions to create log streams and put log events (optional, created when CloudTrail is enabled)

## Documentation

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.0)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (6.21.0)

## Modules

No modules.

## Required Inputs

The following input variables are required:

### <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name)

Description: Name of the S3 bucket to create. Must be globally unique

Type: `string`

### <a name="input_cloudtrail_s3_bucket_name"></a> [cloudtrail\_s3\_bucket\_name](#input\_cloudtrail\_s3\_bucket\_name)

Description: Name of the S3 bucket for CloudTrail logs. Must be a separate dedicated logging bucket (not the bucket being monitored). Required when enable\_cloudtrail is true for AWS Security Hub S3-22 compliance

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region)

Description: AWS region where the S3 bucket will be created

Type: `string`

Default: `"ca-central-1"`

### <a name="input_block_public_access"></a> [block\_public\_access](#input\_block\_public\_access)

Description: Enable all public access block settings for the S3 bucket

Type: `bool`

Default: `true`

### <a name="input_cloudtrail_cloudwatch_log_group_name"></a> [cloudtrail\_cloudwatch\_log\_group\_name](#input\_cloudtrail\_cloudwatch\_log\_group\_name)

Description: Name of the CloudWatch Log Group for CloudTrail logs

Type: `string`

Default: `""`

### <a name="input_cloudtrail_kms_key_alias"></a> [cloudtrail\_kms\_key\_alias](#input\_cloudtrail\_kms\_key\_alias)

Description: Alias for the KMS key used to encrypt CloudTrail logs

Type: `string`

Default: `""`

### <a name="input_cloudtrail_log_retention_days"></a> [cloudtrail\_log\_retention\_days](#input\_cloudtrail\_log\_retention\_days)

Description: Number of days to retain CloudTrail logs in CloudWatch Logs

Type: `number`

Default: `90`

### <a name="input_cloudtrail_name"></a> [cloudtrail\_name](#input\_cloudtrail\_name)

Description: Name of the CloudTrail trail

Type: `string`

Default: `""`

### <a name="input_cloudtrail_s3_key_prefix"></a> [cloudtrail\_s3\_key\_prefix](#input\_cloudtrail\_s3\_key\_prefix)

Description: S3 key prefix for CloudTrail logs

Type: `string`

Default: `"cloudtrail/"`

### <a name="input_enable_cloudtrail"></a> [enable\_cloudtrail](#input\_enable\_cloudtrail)

Description: Enable CloudTrail logging for S3 data events. Required for AWS Security Hub S3-22 compliance (object-level logging for read/write events)

Type: `bool`

Default: `false`

### <a name="input_enable_encryption"></a> [enable\_encryption](#input\_enable\_encryption)

Description: Enable server-side encryption for the S3 bucket

Type: `bool`

Default: `true`

### <a name="input_enable_mfa_delete"></a> [enable\_mfa\_delete](#input\_enable\_mfa\_delete)

Description: Enable MFA delete for the S3 bucket versioning configuration. Required for AWS Security Hub S3-20 compliance. Note: MFA delete is always enabled to meet compliance requirements

Type: `bool`

Default: `true`

### <a name="input_enforce_ssl"></a> [enforce\_ssl](#input\_enforce\_ssl)

Description: Enforce SSL/TLS for all requests to the S3 bucket using bucket policy

Type: `bool`

Default: `true`

### <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy)

Description: Allow destruction of the bucket even if it contains objects

Type: `bool`

Default: `false`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Additional tags to apply to the S3 bucket

Type: `map(string)`

Default: `{}`

## Resources

The following resources are used by this module:

- [aws_cloudtrail.main](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/cloudtrail) (resource)
- [aws_cloudwatch_log_group.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/cloudwatch_log_group) (resource)
- [aws_iam_role.cloudtrail_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/iam_role) (resource)
- [aws_iam_role_policy.cloudtrail_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/iam_role_policy) (resource)
- [aws_kms_alias.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/kms_alias) (resource)
- [aws_kms_key.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/kms_key) (resource)
- [aws_s3_bucket.main](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/s3_bucket) (resource)
- [aws_s3_bucket_policy.main](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/s3_bucket_policy) (resource)
- [aws_s3_bucket_public_access_block.main](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/s3_bucket_public_access_block) (resource)
- [aws_s3_bucket_server_side_encryption_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/s3_bucket_server_side_encryption_configuration) (resource)
- [aws_s3_bucket_versioning.main](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/s3_bucket_versioning) (resource)
- [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/data-sources/caller_identity) (data source)
- [aws_iam_policy_document.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.cloudtrail_assume_role](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.cloudtrail_cloudwatch_policy](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.cloudtrail_kms_policy](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/data-sources/iam_policy_document) (data source)
- [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/data-sources/partition) (data source)
- [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/data-sources/region) (data source)

## Outputs

The following outputs are exported:

### <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn)

Description: The ARN of the S3 bucket

### <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name)

Description: The bucket domain name

### <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id)

Description: The name of the S3 bucket

### <a name="output_bucket_region"></a> [bucket\_region](#output\_bucket\_region)

Description: The AWS region the bucket resides in

### <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name)

Description: The bucket regional domain name

<!-- markdownlint-enable -->
## Documentation References

This module was generated using the following AWS and Terraform documentation:

### AWS Documentation
* [AWS S3 Bucket Overview](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html)
* [S3 Bucket Versioning](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html)
* [S3 Server-Side Encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html)
* [S3 Block Public Access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)
* [S3 Bucket Policies](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-policies.html)
* [S3 MFA Delete](https://docs.aws.amazon.com/AmazonS3/latest/userguide/MultiFactorAuthenticationDelete.html)
* [AWS CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html)
* [CloudTrail Data Events](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/logging-data-events-with-cloudtrail.html)
* [CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html)
* [AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html)
* [CloudTrail Log File Encryption](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/encrypting-cloudtrail-log-files-with-aws-kms.html)
* [AWS Security Hub CloudTrail Controls](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudtrail-controls.html)
* [S3 Bucket Naming Rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html)

### Terraform Provider Documentation
* [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [aws\_s3\_bucket Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
* [aws\_s3\_bucket\_versioning Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket\_versioning)
* [aws\_s3\_bucket\_server\_side\_encryption\_configuration Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket\_server\_side\_encryption\_configuration)
* [aws\_s3\_bucket\_public\_access\_block Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket\_public\_access\_block)
* [aws\_s3\_bucket\_policy Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket\_policy)
* [aws\_cloudtrail Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail)
* [aws\_cloudwatch\_log\_group Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)
* [aws\_kms\_key Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)
* [aws\_kms\_alias Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)
* [aws\_iam\_role Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)
* [aws\_iam\_role\_policy Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role\_policy)
* [aws\_iam\_policy\_document Data Source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)
<!-- END_TF_DOCS -->