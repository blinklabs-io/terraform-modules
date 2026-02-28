# gcp_gke

Creates a GKE standard cluster with VPC, subnet, node pools, and an IAM service account for nodes.

This module provisions:

- VPC network and subnet with secondary IP ranges for pods and services
- GKE cluster using the `terraform-google-modules/kubernetes-engine/google` module
- Node service account with logging, monitoring, and Artifact Registry permissions (created unless a BYO SA is provided)
- Configurable node pools with autoscaling

## Usage

```hcl
module "gke" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=gcp_gke/v0.2.0"

  project_id   = "my-gcp-project"
  cluster_name = "my-cluster"
  region       = "us-central1"
  zones        = ["us-central1-a", "us-central1-b"]

  vpc_cidr = "10.10.0.0/16"

  node_pools = {
    default = {
      machine_type       = "e2-standard-4"
      min_count          = 0
      max_count          = 3
      initial_node_count = 1
      disk_size_gb       = 100
    }
  }
}
```

### Bring-your-own service account

```hcl
module "gke" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=gcp_gke/v0.2.0"

  project_id           = "my-gcp-project"
  cluster_name         = "my-cluster"
  region               = "us-central1"
  vpc_cidr             = "10.10.0.0/16"
  node_service_account = "my-sa@my-gcp-project.iam.gserviceaccount.com"

  node_pools = { default = {} }
}
```

## Requirements

| Name      | Version       |
| --------- | ------------- |
| terraform | >= 1.1, < 2.0 |
| google    | ~> 7          |

## Inputs

### Identity

| Name            | Description                                                     | Type           | Required | Default         |
| --------------- | --------------------------------------------------------------- | -------------- | -------- | --------------- |
| project_id      | GCP project ID to host the cluster in                           | `string`       | Yes      | —               |
| cluster_name    | Cluster name (lowercase letters, digits, hyphens; max 40 chars) | `string`       | Yes      | —               |
| cluster_version | Kubernetes version (e.g. `"1.33"` or `"latest"`)                | `string`       | No       | `"latest"`      |
| region          | GCP region                                                      | `string`       | No       | `"us-central1"` |
| zones           | GCP zones (must belong to the configured region)                | `list(string)` | No       | `[]`            |

### Network

| Name                     | Description                                                                           | Type     | Required | Default             |
| ------------------------ | ------------------------------------------------------------------------------------- | -------- | -------- | ------------------- |
| vpc_cidr                 | Primary CIDR block for the subnetwork                                                 | `string` | Yes      | —                   |
| pod_cidr                 | Secondary CIDR range for pods                                                         | `string` | No       | `"192.168.16.0/20"` |
| services_cidr            | Secondary CIDR range for services                                                     | `string` | No       | `"192.168.0.0/20"`  |
| vpc_name                 | VPC network name. Defaults to `{cluster_name}-vpc`                                    | `string` | No       | `null`              |
| subnet_name              | Subnetwork name. Defaults to `{cluster_name}-subnet`                                  | `string` | No       | `null`              |
| pod_range_name           | Secondary range name for pods. Defaults to `{cluster_name}-pod-range`                 | `string` | No       | `null`              |
| services_range_name      | Secondary range name for services. Defaults to `{cluster_name}-services-range`        | `string` | No       | `null`              |
| enable_ula_internal_ipv6 | Enable ULA internal IPv6 on the VPC                                                   | `bool`   | No       | `false`             |
| stack_type               | IP stack type (`IPV4_ONLY` or `IPV4_IPV6`)                                            | `string` | No       | `"IPV4_ONLY"`       |
| ipv6_access_type         | IPv6 access type (`INTERNAL` or `EXTERNAL`). Required when `stack_type = "IPV4_IPV6"` | `string` | No       | `null`              |

### Node Service Account

| Name                 | Description                                                                                                                                                                                                                                                                                 | Type     | Required | Default |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | -------- | ------- |
| node_service_account | Email of an existing SA to use for node pools. If omitted, a new SA named `{cluster_name}-node` is created and granted the required roles. BYO SA must already have `roles/logging.logWriter`, `roles/monitoring.metricWriter`, `roles/monitoring.viewer`, `roles/artifactregistry.reader`. | `string` | No       | `null`  |

### Node Pools

| Name       | Description                                            | Type                 | Required | Default |
| ---------- | ------------------------------------------------------ | -------------------- | -------- | ------- |
| node_pools | Map of node pool configurations (key = node pool name) | `map(object({...}))` | No       | `{}`    |

Each node pool object supports:

| Attribute          | Description                                            | Default            |
| ------------------ | ------------------------------------------------------ | ------------------ |
| machine_type       | GCE machine type                                       | `"e2-medium"`      |
| zones              | Override zones for this pool (subset of cluster zones) | `[]`               |
| min_count          | Minimum node count (autoscaler lower bound)            | `0`                |
| max_count          | Maximum node count (autoscaler upper bound)            | `3`                |
| initial_node_count | Initial node count on pool creation                    | `1`                |
| disk_size_gb       | Boot disk size in GB                                   | `100`              |
| disk_type          | Boot disk type                                         | `"pd-balanced"`    |
| image_type         | Node OS image                                          | `"COS_CONTAINERD"` |
| preemptible        | Use preemptible VMs                                    | `false`            |
| spot               | Use Spot VMs                                           | `false`            |
| labels             | Kubernetes labels to apply to nodes                    | `{}`               |
| taints             | Kubernetes taints (`[{key, value, effect}]`)           | `[]`               |
| tags               | GCP network tags to apply to nodes                     | `[]`               |

### Cluster Behaviour

| Name                     | Description                                                   | Type     | Required | Default         |
| ------------------------ | ------------------------------------------------------------- | -------- | -------- | --------------- |
| deletion_protection      | Prevent accidental cluster deletion via Terraform             | `bool`   | No       | `true`          |
| release_channel          | Release channel (`UNSPECIFIED`, `RAPID`, `REGULAR`, `STABLE`) | `string` | No       | `"UNSPECIFIED"` |
| remove_default_node_pool | Remove the default node pool on cluster creation              | `bool`   | No       | `true`          |

### Add-ons

| Name                            | Description                           | Default |
| ------------------------------- | ------------------------------------- | ------- |
| http_load_balancing             | Enable HTTP load balancer add-on      | `true`  |
| horizontal_pod_autoscaling      | Enable Horizontal Pod Autoscaler      | `true`  |
| enable_vertical_pod_autoscaling | Enable Vertical Pod Autoscaling       | `false` |
| network_policy                  | Enable network policy (Calico)        | `false` |
| dns_cache                       | Enable NodeLocal DNSCache             | `false` |
| gce_pd_csi_driver               | Enable GCE Persistent Disk CSI driver | `true`  |
| filestore_csi_driver            | Enable Filestore CSI driver           | `false` |
| gcs_fuse_csi_driver             | Enable GCS Fuse CSI driver            | `false` |

### Monitoring & Logging

| Name                                 | Description                      | Default |
| ------------------------------------ | -------------------------------- | ------- |
| monitoring_enable_managed_prometheus | Enable Google Managed Prometheus | `false` |
| monitoring_enabled_components        | Monitoring components to enable  | `[]`    |
| logging_enabled_components           | Logging components to enable     | `[]`    |

### Security

| Name                       | Description                                            | Default |
| -------------------------- | ------------------------------------------------------ | ------- |
| enable_shielded_nodes      | Enable Shielded Nodes features                         | `true`  |
| master_authorized_networks | CIDR blocks allowed to reach the Kubernetes API server | `[]`    |

### Maintenance

| Name                   | Description                                              | Default   |
| ---------------------- | -------------------------------------------------------- | --------- |
| maintenance_start_time | Daily maintenance window start (RFC3339, e.g. `"05:00"`) | `"05:00"` |
| maintenance_end_time   | Daily maintenance window end (RFC3339). Empty = no end   | `""`      |
| maintenance_recurrence | Recurrence rule (RFC5545). Empty = daily                 | `""`      |

## Outputs

| Name                   | Description                                                                      |
| ---------------------- | -------------------------------------------------------------------------------- |
| cluster_name           | GKE cluster name                                                                 |
| cluster_endpoint       | GKE cluster API endpoint (sensitive)                                             |
| cluster_ca_certificate | GKE cluster CA certificate (sensitive)                                           |
| node_service_account   | Node pool service account email                                                  |
| vpc                    | VPC details: `name`, `id`, `subnetwork`, `subnetwork_id`, `subnetwork_self_link` |

## Features enabled by default

- HTTP load balancing
- Horizontal Pod Autoscaling
- Shielded nodes
- GCE Persistent Disk CSI driver
- Workload Identity (via upstream module)
- Auto-repair and auto-upgrade on all node pools
