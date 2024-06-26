#################################
#       backup-s3-bucket        #
#################################

resource "aws_s3_bucket" "backup" {
  bucket        = module.label_backup_bucket.name
  force_destroy = var.force_destroy

  tags = module.label_backup_bucket.tags
}

resource "aws_s3_bucket_ownership_controls" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_acl" "backup" {
  bucket = aws_s3_bucket.backup.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.backup
  ]
}

resource "aws_s3_bucket_public_access_block" "backup" {
  bucket = aws_s3_bucket.backup.id

  block_public_acls       = var.enable_public_access_block ? true : false
  block_public_policy     = var.enable_public_access_block ? true : false
  ignore_public_acls      = var.enable_public_access_block ? true : false
  restrict_public_buckets = var.enable_public_access_block ? true : false
}

resource "aws_s3_bucket_versioning" "backup" {
  bucket = aws_s3_bucket.backup.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "backup" {
  count  = var.object_lock_configuration.enabled ? 1 : 0
  bucket = aws_s3_bucket.backup.id

  rule {
    default_retention {
      mode = var.object_lock_configuration.mode
      days = var.object_lock_configuration.days
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    id     = var.lifecycle_configuration["backup"].id
    status = var.lifecycle_configuration["backup"].status

    filter {
      prefix = var.lifecycle_configuration["backup"].prefix
    }

    expiration {
      days = var.lifecycle_configuration["backup"].expiration_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_configuration["backup"].expiration_days
    }

    transition {
      days          = var.lifecycle_configuration["backup"].transition_days
      storage_class = var.lifecycle_configuration["backup"].storage_class
    }

    noncurrent_version_transition {
      noncurrent_days = var.lifecycle_configuration["backup"].transition_days
      storage_class   = var.lifecycle_configuration["backup"].storage_class
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.backup
  ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.id
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "backup" {
  bucket = aws_s3_bucket.backup.id

  target_bucket = aws_s3_bucket.log.id
  target_prefix = "log/"
}

#################################
#        log-s3-bucket          #
#################################

resource "aws_s3_bucket" "log" {
  bucket        = module.label_log_bucket.name
  force_destroy = var.force_destroy

  tags = module.label_log_bucket.tags
}

resource "aws_s3_bucket_acl" "log" {
  bucket = aws_s3_bucket.log.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_public_access_block" "log" {
  bucket = aws_s3_bucket.log.id

  block_public_acls       = var.enable_public_access_block ? true : false
  block_public_policy     = var.enable_public_access_block ? true : false
  ignore_public_acls      = var.enable_public_access_block ? true : false
  restrict_public_buckets = var.enable_public_access_block ? true : false
}

resource "aws_s3_bucket_lifecycle_configuration" "log" {
  bucket = aws_s3_bucket.log.id

  rule {
    id     = var.lifecycle_configuration["log"].id
    status = var.lifecycle_configuration["log"].status

    filter {
      prefix = var.lifecycle_configuration["log"].prefix
    }

    expiration {
      days = var.lifecycle_configuration["log"].expiration_days
    }

    transition {
      days          = var.lifecycle_configuration["log"].transition_days
      storage_class = var.lifecycle_configuration["log"].storage_class
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log" {
  bucket = aws_s3_bucket.log.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}