variable "project" {
  description = "GCP project ID that owns the key ring"
  type        = string
}

variable "location" {
  description = "Location of the key ring, such as a region, a multi-region like us, or global. Cannot be changed after creation"
  type        = string
}

variable "name" {
  description = "Name of the key ring. Key rings cannot be deleted from GCP, so the name is permanently reserved in the project and location"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,63}$", var.name))
    error_message = "name must be 1-63 letters, digits, underscores, or hyphens."
  }
}

variable "keys" {
  description = <<-EOT
    Crypto keys to create in the key ring, keyed by key name.
    purpose is ENCRYPT_DECRYPT, ASYMMETRIC_SIGN, ASYMMETRIC_DECRYPT, RAW_ENCRYPT_DECRYPT, or MAC.
    rotation_period is a duration of at least 86400 seconds such as 7776000s, valid only for ENCRYPT_DECRYPT keys; null disables automatic rotation.
    version_template sets the algorithm and protection_level (SOFTWARE, HSM, EXTERNAL, or EXTERNAL_VPC) of new versions and is required for every purpose except ENCRYPT_DECRYPT.
    EXTERNAL and EXTERNAL_VPC keys are created without a key version; create the version, with its external key URI or path, outside this module.
    crypto_key_backend is the EKM connection, projects/{project}/locations/{location}/ekmConnections/{name}, and is valid only for EXTERNAL_VPC keys; it cannot be changed after the key is created.
    destroy_scheduled_duration is how long a destroyed key version stays recoverable, in seconds such as 2592000s; it cannot be changed after the key is created.
    iam_members maps a role to the members granted that role on the key, additively. Members are any IAM principal string, including principalSet:// and principal:// workload identity values, and must be known at plan time.
  EOT
  type = map(object({
    purpose         = optional(string, "ENCRYPT_DECRYPT")
    rotation_period = optional(string)
    version_template = optional(object({
      algorithm        = string
      protection_level = optional(string, "SOFTWARE")
    }))
    crypto_key_backend         = optional(string)
    destroy_scheduled_duration = optional(string)
    labels                     = optional(map(string), {})
    iam_members                = optional(map(list(string)), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for k in keys(var.keys) : can(regex("^[a-zA-Z0-9_-]{1,63}$", k))])
    error_message = "keys names must be 1-63 letters, digits, underscores, or hyphens."
  }

  validation {
    condition = alltrue([
      for k in values(var.keys) :
      contains(["ENCRYPT_DECRYPT", "ASYMMETRIC_SIGN", "ASYMMETRIC_DECRYPT", "RAW_ENCRYPT_DECRYPT", "MAC"], k.purpose)
    ])
    error_message = "keys purpose must be ENCRYPT_DECRYPT, ASYMMETRIC_SIGN, ASYMMETRIC_DECRYPT, RAW_ENCRYPT_DECRYPT, or MAC."
  }

  validation {
    condition = alltrue([
      for k in values(var.keys) :
      k.rotation_period == null || (
        can(regex("^[0-9]+s$", k.rotation_period)) &&
        try(tonumber(trimsuffix(k.rotation_period, "s")) >= 86400, false) &&
        k.purpose == "ENCRYPT_DECRYPT"
      )
    ])
    error_message = "keys rotation_period must be null or at least 86400 seconds ending in s, for example 7776000s, and is only valid for ENCRYPT_DECRYPT keys."
  }

  validation {
    condition = alltrue([
      for k in values(var.keys) :
      k.version_template != null || k.purpose == "ENCRYPT_DECRYPT"
    ])
    error_message = "keys version_template is required for every purpose except ENCRYPT_DECRYPT."
  }

  # Older Terraform evaluates both operands of ||, so a null version_template
  # must be guarded with a conditional before reading its attributes.
  validation {
    condition = alltrue([
      for k in values(var.keys) :
      k.version_template == null ? true : contains(["SOFTWARE", "HSM", "EXTERNAL", "EXTERNAL_VPC"], k.version_template.protection_level)
    ])
    error_message = "keys version_template protection_level must be SOFTWARE, HSM, EXTERNAL, or EXTERNAL_VPC."
  }

  validation {
    condition = alltrue([
      for k in values(var.keys) :
      k.crypto_key_backend == null ? true : (k.version_template == null ? false : k.version_template.protection_level == "EXTERNAL_VPC")
    ])
    error_message = "keys crypto_key_backend is only valid for EXTERNAL_VPC keys."
  }

  validation {
    condition = alltrue([
      for k in values(var.keys) :
      k.destroy_scheduled_duration == null || can(regex("^[0-9]+s$", k.destroy_scheduled_duration))
    ])
    error_message = "keys destroy_scheduled_duration must be null or a number of seconds ending in s, for example 2592000s."
  }
}

variable "deletion_policy" {
  description = "Deletion policy for every crypto key. PREVENT fails any Terraform destroy or replacement of a key, ABANDON removes a key from state without changing it in GCP, DELETE allows destroy, which destroys every version of the key."
  type        = string
  default     = "PREVENT"

  validation {
    condition     = contains(["PREVENT", "ABANDON", "DELETE"], var.deletion_policy)
    error_message = "deletion_policy must be one of: PREVENT, ABANDON, DELETE."
  }
}
