variable "context" {
  description = <<-EOT
    Naming context used by naming convention module
  EOT
  type        = any
  default = {
    enabled             = true
    namespace           = null
    environment         = null
    stage               = null
    name                = null
    delimiter           = null
    attributes          = []
    tags                = {}
    additional_tag_map  = {}
    regex_replace_chars = null
    label_order         = []
    id_length_limit     = null
    label_key_case      = null
    label_value_case    = null
    descriptor_formats  = {}
    labels_as_tags      = ["unset"]
  }

  validation {
    condition = lookup(var.context, "label_key_case", null) == null ? true : contains([
      "lower", "title", "upper"
    ], var.context["label_key_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }

  validation {
    condition = lookup(var.context, "label_value_case", null) == null ? true : contains([
      "lower", "title", "upper", "none"
    ], var.context["label_value_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}

#################################
#            s3                 #
#################################

variable "enable_public_access_block" {
  description = "Enable public access block for the S3 bucket. If enabled, all public access settings will be set to true."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = " A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "object_lock_configuration" {
  description = <<-EOT
    Configuration block for object locking.
    If enabled days must be passed.
    Mode can be GOVERNANCE or COMPLIANCE.
    COMPLIANCE objects can not be deleted anyway (bar account delete) until the days or years are passed.
  EOT
  type = object({
    enabled = bool
    mode    = string
    days    = number
  })
  default = {
    enabled = false
    mode    = null
    days    = null
  }
  validation {
    condition     = var.object_lock_configuration.days != null || !var.object_lock_configuration.enabled
    error_message = "If object locking is enabled then days must be provided."
  }
  validation {
    condition = (var.object_lock_configuration.mode == "GOVERNANCE" ||
      var.object_lock_configuration.mode == "COMPLIANCE" ||
    !var.object_lock_configuration.enabled)
    error_message = "If object locking is enabled then mode must be either COMPLIANCE or GOVERNANCE."
  }
}

variable "lifecycle_configuration" {
  description = "Lifecycle configuration settings"
  type = object({
    status          = string
    expiration_days = number
    transition_days = number
    storage_class   = string
  })
  default = {
    status          = "Enabled"
    expiration_days = 180
    transition_days = 0
    storage_class   = "STANDARD_IA"
  }
  validation {
    condition     = contains(["Enabled", "Disabled"], var.lifecycle_configuration.status)
    error_message = "Status must be either 'Enabled' or 'Disabled'."
  }
  validation {
    condition     = contains(["STANDARD_IA", "GLACIER_IR"], var.lifecycle_configuration.storage_class)
    error_message = "Storage class must be either 'STANDARD_IA' or 'GLACIER_IR'."
  }
  validation {
    condition     = var.lifecycle_configuration.expiration_days > 0
    error_message = "Expiration days must be a positive integer."
  }
  validation {
    condition     = var.lifecycle_configuration.transition_days == 0
    error_message = "Transition days can only be 0."
  }
}
