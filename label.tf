module "label_bucket" {
  source  = "cloudposse/label/null"
  context = var.context
}

module "label_kms" {
  source  = "cloudposse/label/null"
  context = merge(var.context, { name = "backup-kms" })
}
