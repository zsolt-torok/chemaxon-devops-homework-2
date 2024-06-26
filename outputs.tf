output "bucket_name" {
  description = "The name of the created S3 bucket"
  value       = aws_s3_bucket.content.bucket
}

output "bucket_arn" {
  description = "The ARN of the created S3 bucket"
  value       = aws_s3_bucket.content.arn
}

output "bucket_region" {
  description = "The AWS region of the created S3 bucket"
  value       = aws_s3_bucket.content.region
}

output "kms_key_id" {
  description = "The ID of the KMS key used for S3 bucket encryption"
  value       = aws_kms_key.this.id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for S3 bucket encryption"
  value       = aws_kms_key.this.arn
}
