variable "name" {
  description = "Name used for the compute instance and associated resources."
  type        = string
}
variable "machine_type" {
  description = "GCP machine type, e.g. e2-medium."
  type        = string
}
variable "project" {
  description = "GCP project ID where resources will be created."
  type        = string
}
variable "zone" {
  description = "GCP zone for the instance. Region is derived automatically."
  type        = string
  default     = "us-central1-a"
}
variable "disk_size" {
  description = "Boot disk size in GB."
  type        = number
  default     = 500
}
variable "image" {
  description = "Boot disk image."
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2404-lts"
}
variable "tags" {
  description = "Network tags for the instance."
  type        = list(string)
  default     = []
}
variable "use_default_network" {
  description = "Use GCP's default network instead of creating a custom VPC."
  type        = bool
  default     = false
}
variable "ip_cidr_range" {
  description = "Subnet CIDR range for the custom VPC. Ignored when use_default_network is true."
  type        = string
  default     = "10.0.0.0/24"
}
variable "metadata" {
  description = "Metadata key/value pairs for the instance. block-project-ssh-keys is set to true by default."
  type        = map(string)
  default     = {}
}
variable "allow_ports" {
  description = "List of TCP ports to allow ingress from allow_source_ranges. Only applies to custom VPC."
  type        = list(number)
  default     = [22]
}
variable "service_account_email" {
  description = "Service account email to attach to the instance. Omitted if null."
  type        = string
  default     = null
}
variable "service_account_scopes" {
  description = "OAuth scopes for the service account."
  type        = list(string)
  default = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/trace.append",
  ]
}

variable "allow_source_ranges" {
  description = "Source CIDR ranges allowed by the firewall rule. Only applies to custom VPC."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.allow_source_ranges) > 0
    error_message = "allow_source_ranges must contain at least one CIDR range."
  }
}

variable "confidential_instance_type" {
  description = "Confidential VM technology: SEV, SEV_SNP or TDX. Disabled if null. Forces on_host_maintenance to TERMINATE, and SEV_SNP sets min_cpu_platform to AMD Milan; the machine type and image must support it. Changing it replaces the instance; resetting it to null does not disable it on an existing instance."
  type        = string
  default     = null

  validation {
    condition     = var.confidential_instance_type == null || contains(["SEV", "SEV_SNP", "TDX"], coalesce(var.confidential_instance_type, "-"))
    error_message = "confidential_instance_type must be null, SEV, SEV_SNP or TDX."
  }
}

variable "shielded_instance_config" {
  description = "Shielded VM settings. The block is omitted if null, which leaves the current setting unchanged. Changing it on a running instance fails because the instance must be stopped."
  type = object({
    enable_secure_boot          = optional(bool, false)
    enable_vtpm                 = optional(bool, true)
    enable_integrity_monitoring = optional(bool, true)
  })
  default = null
}

variable "spot" {
  description = "Run the instance as a Spot VM (preemptible, no automatic restart). Enabling it replaces the instance; resetting it to false does not convert an existing instance back."
  type        = bool
  default     = false
}

variable "instance_termination_action" {
  description = "Action when a Spot VM is preempted: STOP or DELETE. Only used when spot is true."
  type        = string
  default     = "STOP"

  validation {
    condition     = contains(["STOP", "DELETE"], var.instance_termination_action)
    error_message = "instance_termination_action must be STOP or DELETE."
  }
}
