output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_id" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_region" {
  description = "The AWS region the bucket resides in"
  value       = aws_s3_bucket.main.region
}

output "bucket_regional_domain_name" {
  description = "The bucket regional domain name"
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}
