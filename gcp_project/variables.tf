variable "gcp_organization_id" {
  description = "GCP organization ID (numeric). Either gcp_organization_id or gcp_folder_id must be provided."
  type        = string
  default     = null

  validation {
    condition     = var.gcp_organization_id == null || can(regex("^[0-9]+$", var.gcp_organization_id))
    error_message = "GCP organization ID must be numeric."
  }
}

variable "gcp_folder_id" {
  description = "GCP folder ID (numeric). Projects will be created under this folder by default. Either gcp_organization_id or gcp_folder_id must be provided."
  type        = string
  default     = null

  validation {
    condition     = var.gcp_folder_id == null || can(regex("^[0-9]+$", var.gcp_folder_id))
    error_message = "GCP folder ID must be numeric."
  }
}

variable "gcp_billing_account" {
  description = "GCP billing account ID applied to all projects unless overridden per project."
  type        = string
  default     = null

  validation {
    condition     = var.gcp_billing_account == null || can(regex("^[0-9A-Z]{6}-[0-9A-Z]{6}-[0-9A-Z]{6}$", var.gcp_billing_account))
    error_message = "GCP billing account ID must be in format: XXXXXX-XXXXXX-XXXXXX."
  }
}

variable "services" {
  description = "Google services to enable across all created projects"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for s in var.services : can(regex("^[a-z0-9.-]+\\.googleapis\\.com$", s))])
    error_message = "Each service must be a valid GCP service name ending in .googleapis.com (e.g. storage.googleapis.com)."
  }
}

variable "env_vars" {
  description = "Environment variables containing project configuration"
  type = object({
    google = object({
      projects = list(object({
        project_id      = string
        display_name    = optional(string)
        admin           = optional(bool, false)
        network         = optional(bool, false)
        firebase        = optional(bool, false)
        services        = optional(list(string), [])
        folder_id       = optional(string)
        billing_account = optional(string)
      }))
    })
  })
  default = {
    google = {
      projects = []
    }
  }

  validation {
    condition = alltrue([
      for p in var.env_vars.google.projects :
      can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", p.project_id))
    ])
    error_message = "project_id must be 6-30 characters, start with a lowercase letter, end with a letter or digit, and contain only lowercase letters, numbers, and hyphens."
  }

  validation {
    condition = length(var.env_vars.google.projects) == length(distinct([
      for p in var.env_vars.google.projects : p.project_id
    ]))
    error_message = "project_id values must be unique."
  }

  validation {
    condition = length([
      for p in var.env_vars.google.projects : p.project_id if p.admin
    ]) <= 1
    error_message = "At most one project can be designated as admin (admin = true)."
  }

  validation {
    condition = alltrue([
      for p in var.env_vars.google.projects :
      p.display_name == null ? true : length(p.display_name) >= 4 && length(p.display_name) <= 30
    ])
    error_message = "Project display names must be between 4 and 30 characters."
  }

  validation {
    condition = alltrue([
      for p in var.env_vars.google.projects :
      alltrue([for s in p.services : can(regex("^[a-z0-9.-]+\\.googleapis\\.com$", s))])
    ])
    error_message = "Per-project services must be valid GCP service names ending in .googleapis.com (e.g. storage.googleapis.com)."
  }

  validation {
    condition = alltrue([
      for p in var.env_vars.google.projects :
      p.folder_id == null || can(regex("^[0-9]+$", p.folder_id))
    ])
    error_message = "Per-project folder IDs must be numeric."
  }

  validation {
    condition = alltrue([
      for p in var.env_vars.google.projects :
      p.billing_account == null || can(regex("^[0-9A-Z]{6}-[0-9A-Z]{6}-[0-9A-Z]{6}$", p.billing_account))
    ])
    error_message = "Per-project billing account IDs must be in format: XXXXXX-XXXXXX-XXXXXX."
  }
}

variable "enable_terraform_runner" {
  description = "Whether to create and configure the terraform-runner service account"
  type        = bool
  default     = false
}

variable "export_terraform_runner_key" {
  description = "When true, emit the terraform-runner service account key (base64-encoded) as a sensitive output. Defaults to false to avoid storing raw key material in state unnecessarily."
  type        = bool
  default     = false
}

variable "terraform_runner_account_id" {
  description = "Service account ID for the terraform runner"
  type        = string
  default     = "terraform-runner"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.terraform_runner_account_id))
    error_message = "Service account ID must be 6-30 characters, start with a lowercase letter, end with a letter or digit, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "terraform_runner_roles" {
  description = "IAM roles to assign to the terraform-runner service account"
  type        = list(string)
  default = [
    "resourcemanager.projectCreator"
  ]

  validation {
    condition = alltrue([
      for role in var.terraform_runner_roles :
      can(regex("^[a-zA-Z0-9.]+$", role))
    ])
    error_message = "IAM roles must contain only letters, numbers, and dots."
  }
}

variable "deletion_policy" {
  description = "Deletion policy for all created projects. PREVENT protects against destroy, ABANDON removes from state without deleting the GCP project, DELETE deletes the project."
  type        = string
  default     = "PREVENT"

  validation {
    condition     = contains(["PREVENT", "ABANDON", "DELETE"], var.deletion_policy)
    error_message = "deletion_policy must be one of: PREVENT, ABANDON, DELETE."
  }
}

variable "project_create_timeout" {
  description = "Timeout for creating projects"
  type        = string
  default     = "10m"

  validation {
    condition     = can(regex("^[0-9]+(s|m|h)$", var.project_create_timeout))
    error_message = "Timeout must be in format like '10m', '30s', '1h'."
  }
}

variable "project_update_timeout" {
  description = "Timeout for updating projects"
  type        = string
  default     = "10m"

  validation {
    condition     = can(regex("^[0-9]+(s|m|h)$", var.project_update_timeout))
    error_message = "Timeout must be in format like '10m', '30s', '1h'."
  }
}

variable "project_delete_timeout" {
  description = "Timeout for deleting projects"
  type        = string
  default     = "10m"

  validation {
    condition     = can(regex("^[0-9]+(s|m|h)$", var.project_delete_timeout))
    error_message = "Timeout must be in format like '10m', '30s', '1h'."
  }
}

variable "service_create_timeout" {
  description = "Timeout for enabling services"
  type        = string
  default     = "30m"

  validation {
    condition     = can(regex("^[0-9]+(s|m|h)$", var.service_create_timeout))
    error_message = "Timeout must be in format like '30m', '30s', '1h'."
  }
}

variable "service_update_timeout" {
  description = "Timeout for updating services"
  type        = string
  default     = "30m"

  validation {
    condition     = can(regex("^[0-9]+(s|m|h)$", var.service_update_timeout))
    error_message = "Timeout must be in format like '30m', '30s', '1h'."
  }
}

variable "service_disable_on_destroy" {
  description = "Whether to disable a Google service when its resource is destroyed. Set to true if you want services removed from the project when deleted from Terraform config. Defaults to false to prevent accidental service disruption."
  type        = bool
  default     = false
}
