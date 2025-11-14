<!-- BEGIN_TF_DOCS -->
# AWS S3 Bucket Terraform Module

This Terraform module provisions and manages an AWS S3 bucket with security best practices enabled by default.

The module provides a simple, secure way to create S3 buckets with optional versioning, server-side encryption, and public access blocking.

## Permissions

### AWS Permissions

To provision resources, the AWS provider requires credentials with appropriate IAM permissions. The following permissions are required:

* `s3:CreateBucket` - Create S3 buckets
* `s3:DeleteBucket` - Delete S3 buckets
* `s3:PutBucketVersioning` - Configure bucket versioning
* `s3:PutEncryptionConfiguration` - Configure server-side encryption
* `s3:PutBucketPublicAccessBlock` - Configure public access block settings
* `s3:PutBucketLogging` - Configure bucket logging
* `s3:GetBucketVersioning` - Read bucket versioning configuration
* `s3:GetEncryptionConfiguration` - Read encryption configuration
* `s3:GetBucketPublicAccessBlock` - Read public access block settings
* `s3:GetBucketLogging` - Read bucket logging configuration
* `s3:ListBucket` - List bucket contents
* `s3:PutBucketTagging` - Apply tags to buckets
* `s3:GetBucketTagging` - Read bucket tags

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
  * Public access blocking enabled by default
  * Bucket versioning enabled by default
  * MFA delete support for versioning protection
* **Access Logging**: Optional server access logging for audit and compliance
* **Flexible Configuration**: All security features can be optionally disabled
* **Bucket Name Validation**: Input validation ensures bucket names meet AWS requirements
* **Tagging Support**: Apply custom tags and automatic management tags
* **Conditional Resources**: Uses count meta-argument for optional feature management
* **Latest Provider**: Uses AWS provider version 6.21.0

## Resources Provisioned

This module provisions the following AWS resources:

* **aws\_s3\_bucket** - Main S3 bucket resource
* **aws\_s3\_bucket\_versioning** - Bucket versioning configuration with MFA delete support (optional, enabled by default)
* **aws\_s3\_bucket\_server\_side\_encryption\_configuration** - Server-side encryption with AES256 (optional, enabled by default)
* **aws\_s3\_bucket\_public\_access\_block** - Public access block settings (optional, enabled by default)
* **aws\_s3\_bucket\_logging** - Server access logging configuration (optional, disabled by default)

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

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region)

Description: AWS region where the S3 bucket will be created

Type: `string`

Default: `"us-east-1"`

### <a name="input_block_public_access"></a> [block\_public\_access](#input\_block\_public\_access)

Description: Enable all public access block settings for the S3 bucket

Type: `bool`

Default: `true`

### <a name="input_enable_encryption"></a> [enable\_encryption](#input\_enable\_encryption)

Description: Enable server-side encryption for the S3 bucket

Type: `bool`

Default: `true`

### <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging)

Description: Enable server access logging for the S3 bucket

Type: `bool`

Default: `false`

### <a name="input_enable_mfa_delete"></a> [enable\_mfa\_delete](#input\_enable\_mfa\_delete)

Description: Enable MFA delete for the S3 bucket versioning configuration. Versioning must be enabled

Type: `bool`

Default: `false`

### <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning)

Description: Enable versioning for the S3 bucket

Type: `bool`

Default: `true`

### <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy)

Description: Allow destruction of the bucket even if it contains objects

Type: `bool`

Default: `false`

### <a name="input_logging_target_bucket"></a> [logging\_target\_bucket](#input\_logging\_target\_bucket)

Description: Name of the target bucket for access logs. If not provided and logging is enabled, logs will be stored in the same bucket

Type: `string`

Default: `""`

### <a name="input_logging_target_prefix"></a> [logging\_target\_prefix](#input\_logging\_target\_prefix)

Description: Prefix for all log object keys

Type: `string`

Default: `"logs/"`

### <a name="input_project_name"></a> [project\_name](#input\_project\_name)

Description: Name of the project for tagging resources

Type: `string`

Default: `"s3-bucket-project"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Additional tags to apply to the S3 bucket

Type: `map(string)`

Default: `{}`

## Resources

The following resources are used by this module:

- [aws_s3_bucket.main](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/s3_bucket) (resource)
- [aws_s3_bucket_logging.main](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/s3_bucket_logging) (resource)
- [aws_s3_bucket_public_access_block.main](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/s3_bucket_public_access_block) (resource)
- [aws_s3_bucket_server_side_encryption_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/s3_bucket_server_side_encryption_configuration) (resource)
- [aws_s3_bucket_versioning.main](https://registry.terraform.io/providers/hashicorp/aws/6.21.0/docs/resources/s3_bucket_versioning) (resource)

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
* [S3 Server Access Logging](https://docs.aws.amazon.com/AmazonS3/latest/userguide/ServerLogs.html)
* [S3 MFA Delete](https://docs.aws.amazon.com/AmazonS3/latest/userguide/MultiFactorAuthenticationDelete.html)
* [S3 Bucket Naming Rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html)

### Terraform Provider Documentation
* [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [aws\_s3\_bucket Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
* [aws\_s3\_bucket\_versioning Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket\_versioning)
* [aws\_s3\_bucket\_server\_side\_encryption\_configuration Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket\_server\_side\_encryption\_configuration)
* [aws\_s3\_bucket\_public\_access\_block Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket\_public\_access\_block)
* [aws\_s3\_bucket\_logging Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket\_logging)
<!-- END_TF_DOCS -->