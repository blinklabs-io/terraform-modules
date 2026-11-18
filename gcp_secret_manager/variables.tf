variable "project" {
  description = "GCP project ID that holds the secrets"
  type        = string
}

variable "secrets" {
  description = "Secret Manager secrets to create, keyed by secret ID. Secrets are created without versions; values are added out of band so they never enter Terraform state"
  type = map(object({
    labels                = optional(map(string), {})
    annotations           = optional(map(string), {})
    version_destroy_ttl   = optional(string)
    kms_key_name          = optional(string)
    replication_locations = optional(map(object({ kms_key_name = optional(string) })), {})
    iam_members           = optional(map(list(string)), {})
    deletion_protection   = optional(bool, true)
  }))
  default = {}

  validation {
    condition     = alltrue([for k in keys(var.secrets) : can(regex("^[a-zA-Z0-9_-]{1,255}$", k))])
    error_message = "secrets keys must be 1-255 letters, digits, underscores, or hyphens."
  }

  validation {
    condition = alltrue([
      for s in values(var.secrets) : s.version_destroy_ttl == null || can(regex("^[0-9]+s$", s.version_destroy_ttl))
    ])
    error_message = "version_destroy_ttl must be a duration in seconds, such as \"86400s\"."
  }

  validation {
    condition = alltrue([
      for s in values(var.secrets) : s.kms_key_name == null || length(s.replication_locations) == 0
    ])
    error_message = "kms_key_name applies to automatic replication; with replication_locations, set kms_key_name on each location instead."
  }

  validation {
    condition = alltrue([
      for s in values(var.secrets) : alltrue([for members in values(s.iam_members) : length(members) > 0])
    ])
    error_message = "Each iam_members role must list at least one member."
  }

  validation {
    condition = alltrue([
      for s in values(var.secrets) : alltrue([for members in values(s.iam_members) : length(distinct(members)) == length(members)])
    ])
    error_message = "Each iam_members role must not list the same member twice."
  }
}
