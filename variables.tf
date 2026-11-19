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

variable "project_iam_members" {
  description = "List of project-level IAM member bindings"
  type = list(object({
    project = string
    role    = string
    member  = string
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

variable "workload_identity_pools" {
  description = "Workload identity pools with OIDC or AWS providers for external identities"
  type = list(object({
    pool_id      = string
    display_name = optional(string)
    description  = optional(string)
    project      = optional(string)
    disabled     = optional(bool, false)
    providers = optional(list(object({
      provider_id         = string
      display_name        = optional(string)
      description         = optional(string)
      issuer_uri          = optional(string)
      aws_account_id      = optional(string)
      allowed_audiences   = optional(list(string), [])
      attribute_mapping   = map(string)
      attribute_condition = string
    })), [])
  }))
  default = []

  validation {
    condition = alltrue(flatten([
      for p in var.workload_identity_pools : [
        for pr in p.providers :
        (pr.issuer_uri != null) != (pr.aws_account_id != null)
      ]
    ]))
    error_message = "Each workload identity provider must set exactly one of issuer_uri or aws_account_id."
  }

  validation {
    condition = alltrue(flatten([
      for p in var.workload_identity_pools : [
        for pr in p.providers : try(trimspace(pr.attribute_condition), "") != ""
      ]
    ]))
    error_message = "Each workload identity provider must set attribute_condition; without one, any identity from the issuer can authenticate."
  }
}

variable "workload_identity_pool_bindings" {
  description = "Grants roles/iam.workloadIdentityUser on a service account to principals from a workload identity pool, selected by subject or by a mapped attribute"
  type = list(object({
    service_account_id    = optional(string)
    service_account_email = optional(string)
    project               = optional(string)
    pool_id               = string
    attribute             = string
    value                 = string
  }))
  default = []

  validation {
    condition = alltrue([
      for b in var.workload_identity_pool_bindings :
      (b.service_account_id == null) != (b.service_account_email == null)
    ])
    error_message = "Each workload_identity_pool_binding must have exactly one of service_account_id or service_account_email set, not both or neither."
  }

  validation {
    condition = alltrue([
      for b in var.workload_identity_pool_bindings :
      can(regex("^(subject|group|attribute\\.[a-z0-9_]{1,100})$", b.attribute))
    ])
    error_message = "attribute must be subject, group, or attribute.<name>, where name is 1-100 lowercase letters, digits, or underscores."
  }
}
