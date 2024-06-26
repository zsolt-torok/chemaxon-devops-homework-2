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
  type = map(object({
    id              = string
    status          = string
    prefix          = string
    expiration_days = number
    transition_days = number
    storage_class   = string
  }))
  default = {
    default = {
      id              = null
      status          = null
      prefix          = null
      expiration_days = null
      transition_days = null
      storage_class   = null
    }
  }
  validation {
    condition = alltrue([
      for _, config in var.lifecycle_configuration :
      contains(["Enabled", "Disabled"], config.status)
    ])
    error_message = "Each status must be either 'Enabled' or 'Disabled'."
  }
  validation {
    condition = alltrue([
      for _, config in var.lifecycle_configuration :
      contains(["STANDARD_IA", "GLACIER_IR", "GLACIER", "ONEZONE_IA", "INTELLIGENT_TIERING", "DEEP_ARCHIVE", "GLACIER_IR"], config.storage_class)
    ])
    error_message = "Each lifecycle configuration storage class must be one of 'STANDARD_IA', 'GLACIER_IR', 'GLACIER', 'ONEZONE_IA', 'INTELLIGENT_TIERING', or 'DEEP_ARCHIVE'."
  }
  validation {
    condition = alltrue([
      for _, config in var.lifecycle_configuration :
      config.expiration_days > 0
    ])
    error_message = "Each expiration_days must be a positive integer."
  }
  validation {
    condition = alltrue([
      for _, config in var.lifecycle_configuration :
      config.transition_days >= 0
    ])
    error_message = "Each lifecycle configuration transition_days must be zero or a positive integer."
  }
}
