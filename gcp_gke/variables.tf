variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string

  validation {
    condition     = length(var.cluster_name) <= 25
    error_message = "Cluster name must be 25 characters or less to allow for service account suffix (-node)."
  }
}

variable "cluster_version" {
  description = "Kubernetes version for the cluster"
  default     = "1.31"
  type        = string
}

variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  default     = "us-central1"
  type        = string
}

variable "zones" {
  description = "GCP zones for the cluster"
  default     = ["us-central1-a", "us-central1-b"]
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.10.0.0/16"
  type        = string
}

variable "pod_cidr" {
  description = "Secondary CIDR range for pods"
  default     = "192.168.16.0/20"
  type        = string
}

variable "services_cidr" {
  description = "Secondary CIDR range for services"
  default     = "192.168.0.0/20"
  type        = string
}

variable "node_pools" {
  description = "Map of node pool configurations"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_private_nodes" {
  description = "Enable private nodes (no public IPs on nodes)"
  type        = bool
  default     = false
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint (control plane not publicly accessible)"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the master network. Required when enable_private_nodes is true."
  type        = string
  default     = "172.16.0.0/28"
}
