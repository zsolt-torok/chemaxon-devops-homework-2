#################################
#       backup-s3-bucket        #
#################################

data "aws_iam_policy_document" "s3_backup_kms_policy" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789012:role/backup_uploader"]
    }
  }
}

data "aws_iam_policy_document" "s3_backup_upload_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.backup.arn}",
      "${aws_s3_bucket.backup.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789012:role/backup_uploader"]
    }
  }

  statement {
    sid       = "RequireObjectEncryption"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.backup.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = ["${aws_kms_key.this.arn}"]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = ["true"]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_backup_upload_policy" {
  bucket = aws_s3_bucket.backup.id
  policy = data.aws_iam_policy_document.s3_backup_upload_policy.json
}

#################################
#        log-s3-bucket          #
#################################

data "aws_iam_policy_document" "s3_log_policy" {

  statement {
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      "${aws_s3_bucket.log.arn}",
      "${aws_s3_bucket.log.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_log_policy" {
  bucket = aws_s3_bucket.log.id
  policy = data.aws_iam_policy_document.s3_log_policy.json
}