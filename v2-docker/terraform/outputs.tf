output "s3_bucket_name" {
  description = "Created S3 bucket name"
  value       = aws_s3_bucket.main.bucket
}

output "s3_bucket_arn" {
  description = "Created S3 bucket ARN"
  value       = aws_s3_bucket.main.arn
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name for the bucket"
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}
