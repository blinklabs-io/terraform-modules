variable "project" {
  description = "Default GCP project ID"
  type        = string
}

variable "service_accounts" {
  description = "List of service accounts to manage"
  type = list(object({
    account_id   = string
    display_name = optional(string)
    description  = optional(string)
    project      = optional(string)
    create_key   = optional(bool, false)
    iam_bindings = optional(list(object({
      role    = string
      project = optional(string)
    })), [])
  }))
  default = []
}

variable "custom_roles" {
  description = "List of custom IAM roles to manage"
  type = list(object({
    role_id     = string
    title       = string
    description = optional(string)
    permissions = list(string)
    project     = optional(string)
  }))
  default = []
}

variable "organization_id" {
  description = "GCP organization ID for organization-level IAM bindings"
  type        = string
  default     = null
}

variable "organization_iam_bindings" {
  description = "List of organization-level IAM role bindings"
  type = list(object({
    role    = string
    members = list(string)
  }))
  default = []
}

variable "workload_identity_bindings" {
  description = "List of workload identity bindings"
  type = list(object({
    service_account_id    = optional(string)
    service_account_email = optional(string)
    namespace             = string
    k8s_service_account   = string
    project               = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for b in var.workload_identity_bindings :
      (b.service_account_id == null) != (b.service_account_email == null)
    ])
    error_message = "Each workload_identity_binding must have exactly one of service_account_id or service_account_email set, not both or neither."
  }
}
