output "backup_bucket_name" {
  description = "The name of the created backup S3 bucket"
  value       = aws_s3_bucket.backup.bucket
}

output "backup_bucket_arn" {
  description = "The ARN of the created backup S3 bucket"
  value       = aws_s3_bucket.backup.arn
}

output "backup_bucket_region" {
  description = "The AWS region of the created backup S3 bucket"
  value       = aws_s3_bucket.backup.region
}

output "log_bucket_name" {
  description = "The name of the created log S3 bucket"
  value       = aws_s3_bucket.log.bucket
}

output "log_bucket_arn" {
  description = "The ARN of the created log S3 bucket"
  value       = aws_s3_bucket.log.arn
}

output "log_bucket_region" {
  description = "The AWS region of the created log S3 bucket"
  value       = aws_s3_bucket.log.region
}

output "kms_key_id" {
  description = "The ID of the KMS key used for S3 backup bucket encryption"
  value       = aws_kms_key.this.id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for S3 backup bucket encryption"
  value       = aws_kms_key.this.arn
}
