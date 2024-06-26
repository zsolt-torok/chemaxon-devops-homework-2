module "label_backup_bucket" {
  source  = "cloudposse/label/null"
  context = var.context
}

module "label_log_bucket" {
  source  = "cloudposse/label/null"
  context = merge(var.context, { name = "log-bucket" })
}

module "label_kms" {
  source  = "cloudposse/label/null"
  context = merge(var.context, { name = "backup-kms" })
}
