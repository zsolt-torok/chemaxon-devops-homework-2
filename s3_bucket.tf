resource "aws_s3_bucket" "content" {
  bucket        = module.label_bucket.name
  force_destroy = var.force_destroy

  tags = module.label_bucket.tags

  # Uncomment and configure as needed
  # logging {
  #   target_bucket = aws_s3_bucket.access_log.id
  # }
  # depends_on = [
  #   aws_s3_bucket_public_access_block.access_log
  # ]
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.content.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.content.id

  block_public_acls       = var.enable_public_access_block ? true : false
  block_public_policy     = var.enable_public_access_block ? true : false
  ignore_public_acls      = var.enable_public_access_block ? true : false
  restrict_public_buckets = var.enable_public_access_block ? true : false
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.content.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.content.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.this
  ]
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = var.object_lock_configuration.enabled ? 1 : 0
  bucket = aws_s3_bucket.content.id

  rule {
    default_retention {
      mode = var.object_lock_configuration.mode
      days = var.object_lock_configuration.days
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.content.id

  rule {
    id     = "backup_clean"
    status = var.lifecycle_configuration.status

    filter {
      prefix = "/"
    }

    expiration {
      days = var.lifecycle_configuration.expiration_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_configuration.expiration_days
    }

    transition {
      days          = var.lifecycle_configuration.transition_days
      storage_class = var.lifecycle_configuration.storage_class
    }

    noncurrent_version_transition {
      noncurrent_days = var.lifecycle_configuration.transition_days
      storage_class   = var.lifecycle_configuration.storage_class
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.this
  ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.content.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.id
      sse_algorithm     = "aws:kms"
    }
  }
}
