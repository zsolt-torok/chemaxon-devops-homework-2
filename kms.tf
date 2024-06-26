resource "aws_kms_key" "this" {
  description = "KMS key for S3 backup bucket encryption"
  policy      = data.aws_iam_policy_document.s3_backup_kms_policy.json
  tags        = module.label_kms.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/s3-backup-key"
  target_key_id = aws_kms_key.this.id
}
