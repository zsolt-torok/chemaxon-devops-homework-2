context = {
  enabled     = true
  namespace   = "chemaxon-hw-2"
  environment = "dev"
  stage       = "test"
  name        = "backup-bucket"
  delimiter   = "-"
  attributes  = []
  tags = {
    Terraform   = "true"
    Environment = "development"
  }
  additional_tag_map  = {}
  regex_replace_chars = "/"
  label_order         = ["namespace", "environment", "name"]
  id_length_limit     = 32
  label_key_case      = "lower"
  label_value_case    = "lower"
  descriptor_formats  = {}
  labels_as_tags      = ["name"]
}

object_lock_configuration = {
  enabled = true
  mode    = "GOVERNANCE"
  days    = 180
}

lifecycle_configuration = {
  backup = {
    id              = "backup-clean"
    status          = "Enabled"
    prefix          = "/"
    expiration_days = 180
    transition_days = 0
    storage_class   = "STANDARD_IA"
  }
  log = {
    id              = "auto-archive"
    status          = "Enabled"
    prefix          = "log/"
    expiration_days = 180
    transition_days = 90
    storage_class   = "GLACIER"
  }
}