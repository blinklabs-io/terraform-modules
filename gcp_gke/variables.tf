# ── Identity ───────────────────────────────────────────────────────────────────

variable "project_id" {
  description = "GCP project ID to host the cluster in."
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster. Must start with a lowercase letter and contain only lowercase letters, digits, and hyphens (max 40 chars)."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9\\-]{0,39}$", var.cluster_name))
    error_message = "cluster_name must start with a lowercase letter and contain only lowercase letters, digits, and hyphens (max 40 chars)."
  }
}

variable "cluster_version" {
  description = "Kubernetes version for the cluster (e.g. '1.33' or 'latest')."
  type        = string
  default     = "latest"
}

variable "region" {
  description = "GCP region to host the cluster in."
  type        = string
  default     = "us-central1"
}

variable "zones" {
  description = "GCP zones for the cluster. All zones must belong to the configured region."
  type        = list(string)
  default     = []
}

# ── Network ────────────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "Primary CIDR block for the subnetwork."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR block (e.g. '10.6.0.0/16')."
  }
}

variable "pod_cidr" {
  description = "Secondary CIDR range for pods."
  type        = string
  default     = "192.168.16.0/20"

  validation {
    condition     = can(cidrnetmask(var.pod_cidr))
    error_message = "pod_cidr must be a valid CIDR block (e.g. '192.168.16.0/20')."
  }
}

variable "services_cidr" {
  description = "Secondary CIDR range for services."
  type        = string
  default     = "192.168.0.0/20"

  validation {
    condition     = can(cidrnetmask(var.services_cidr))
    error_message = "services_cidr must be a valid CIDR block (e.g. '192.168.0.0/20')."
  }
}

variable "vpc_name" {
  description = "Name of the VPC network. Defaults to {cluster_name}-vpc."
  type        = string
  default     = null
}

variable "subnet_name" {
  description = "Name of the subnetwork. Defaults to {cluster_name}-subnet."
  type        = string
  default     = null
}

variable "pod_range_name" {
  description = "Name of the secondary IP range for pods. Defaults to {cluster_name}-pod-range."
  type        = string
  default     = null
}

variable "services_range_name" {
  description = "Name of the secondary IP range for services. Defaults to {cluster_name}-services-range."
  type        = string
  default     = null
}

variable "enable_ula_internal_ipv6" {
  description = "Enable ULA internal IPv6 on the VPC network."
  type        = bool
  default     = false
}

variable "stack_type" {
  description = "IP stack type for the subnetwork (IPV4_ONLY or IPV4_IPV6)."
  type        = string
  default     = "IPV4_ONLY"

  validation {
    condition     = contains(["IPV4_ONLY", "IPV4_IPV6"], var.stack_type)
    error_message = "stack_type must be IPV4_ONLY or IPV4_IPV6."
  }
}

variable "ipv6_access_type" {
  description = "IPv6 access type when stack_type is IPV4_IPV6 (INTERNAL or EXTERNAL). Required when stack_type is IPV4_IPV6."
  type        = string
  default     = null

  validation {
    condition     = var.ipv6_access_type == null || contains(["INTERNAL", "EXTERNAL"], var.ipv6_access_type)
    error_message = "ipv6_access_type must be INTERNAL or EXTERNAL."
  }

  validation {
    condition     = !(var.stack_type == "IPV4_IPV6" && var.ipv6_access_type == null)
    error_message = "ipv6_access_type must be set when stack_type is IPV4_IPV6."
  }
}

# ── Node pools ─────────────────────────────────────────────────────────────────

variable "node_pools" {
  description = "Map of node pool configurations. Each key is the node pool name. Defaults to empty — the cluster is created with no node pools (remove_default_node_pool = true). Callers must provide at least one pool for workloads to be schedulable."
  type = map(object({
    machine_type       = optional(string, "e2-medium")
    zones              = optional(list(string), [])
    min_count          = optional(number, 0)
    max_count          = optional(number, 3)
    initial_node_count = optional(number, 1)
    disk_size_gb       = optional(number, 100)
    disk_type          = optional(string, "pd-balanced")
    image_type         = optional(string, "COS_CONTAINERD")
    preemptible        = optional(bool, false)
    spot               = optional(bool, false)
    labels             = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    tags = optional(list(string), [])
  }))
  default = {}
}

# ── Node service account ───────────────────────────────────────────────────────

variable "node_service_account" {
  description = "Email of an existing service account to use for node pools. If not provided, a new service account named {cluster_name}-node is created and granted roles/logging.logWriter, roles/monitoring.metricWriter, roles/monitoring.viewer, and roles/artifactregistry.reader. When providing a BYO SA, ensure it already has these roles granted in the project."
  type        = string
  default     = null
}

# ── Cluster behaviour ──────────────────────────────────────────────────────────

variable "deletion_protection" {
  description = "Prevent accidental cluster deletion via Terraform. Set to false only for ephemeral or test clusters."
  type        = bool
  default     = true
}

variable "release_channel" {
  description = "The release channel for the cluster (UNSPECIFIED, RAPID, REGULAR, STABLE)."
  type        = string
  default     = "UNSPECIFIED"

  validation {
    condition     = contains(["UNSPECIFIED", "RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be one of: UNSPECIFIED, RAPID, REGULAR, STABLE."
  }
}

variable "remove_default_node_pool" {
  description = "Remove the default node pool on cluster creation."
  type        = bool
  default     = true
}

# ── Add-ons ────────────────────────────────────────────────────────────────────

variable "http_load_balancing" {
  description = "Enable the HTTP load balancer add-on."
  type        = bool
  default     = true
}

variable "horizontal_pod_autoscaling" {
  description = "Enable the Horizontal Pod Autoscaler add-on."
  type        = bool
  default     = true
}

variable "enable_vertical_pod_autoscaling" {
  description = "Enable Vertical Pod Autoscaling."
  type        = bool
  default     = false
}

variable "network_policy" {
  description = "Enable the network policy add-on (Calico). Not compatible with Dataplane V2 / Cilium."
  type        = bool
  default     = false
}

variable "dns_cache" {
  description = "Enable NodeLocal DNSCache."
  type        = bool
  default     = false
}

variable "filestore_csi_driver" {
  description = "Enable the Filestore CSI driver."
  type        = bool
  default     = false
}

variable "gce_pd_csi_driver" {
  description = "Enable the GCE Persistent Disk CSI driver."
  type        = bool
  default     = true
}

variable "gcs_fuse_csi_driver" {
  description = "Enable the GCS Fuse CSI driver."
  type        = bool
  default     = false
}

# ── Monitoring ─────────────────────────────────────────────────────────────────

variable "monitoring_enable_managed_prometheus" {
  description = "Enable Google Managed Prometheus."
  type        = bool
  default     = false
}

variable "monitoring_enabled_components" {
  description = "List of monitoring components to enable (e.g. ['SYSTEM_COMPONENTS', 'APISERVER'])."
  type        = list(string)
  default     = []
}

variable "logging_enabled_components" {
  description = "List of logging components to enable (e.g. ['SYSTEM_COMPONENTS', 'WORKLOADS'])."
  type        = list(string)
  default     = []
}

# ── Security ───────────────────────────────────────────────────────────────────

variable "enable_shielded_nodes" {
  description = "Enable Shielded Nodes features."
  type        = bool
  default     = true
}

variable "master_authorized_networks" {
  description = "List of CIDR blocks allowed to reach the Kubernetes master API."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

# ── Maintenance ────────────────────────────────────────────────────────────────

variable "maintenance_start_time" {
  description = "Daily maintenance window start time in RFC3339 format (e.g. '05:00')."
  type        = string
  default     = "05:00"
}

variable "maintenance_end_time" {
  description = "Daily maintenance window end time in RFC3339 format. Leave empty for no end time."
  type        = string
  default     = ""
}

variable "maintenance_recurrence" {
  description = "Maintenance recurrence in RFC5545 format. Leave empty for daily."
  type        = string
  default     = ""
}
