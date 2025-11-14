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
* `s3:GetBucketVersioning` - Read bucket versioning configuration
* `s3:GetEncryptionConfiguration` - Read encryption configuration
* `s3:GetBucketPublicAccessBlock` - Read public access block settings
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
* **Flexible Configuration**: All security features can be optionally disabled
* **Bucket Name Validation**: Input validation ensures bucket names meet AWS requirements
* **Tagging Support**: Apply custom tags and automatic management tags
* **Conditional Resources**: Uses count meta-argument for optional feature management
* **Latest Provider**: Uses AWS provider version 6.21.0

## Resources Provisioned

This module provisions the following AWS resources:

* **aws_s3_bucket** - Main S3 bucket resource
* **aws_s3_bucket_versioning** - Bucket versioning configuration (optional, enabled by default)
* **aws_s3_bucket_server_side_encryption_configuration** - Server-side encryption with AES256 (optional, enabled by default)
* **aws_s3_bucket_public_access_block** - Public access block settings (optional, enabled by default)
