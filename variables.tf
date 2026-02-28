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
  description = "List of TCP ports to allow ingress from 0.0.0.0/0. Only applies to custom VPC."
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
