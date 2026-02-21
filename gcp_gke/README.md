# gcp_gke

Creates a GKE private cluster with VPC, subnet, node pools, IAM service account, and workload identity enabled.

This module provisions:

- VPC network and subnet with secondary IP ranges for pods and services
- GKE private cluster using the `terraform-google-modules/kubernetes-engine/google//modules/private-cluster` module
- Node service account with logging, monitoring, and artifact registry permissions
- Configurable node pools with autoscaling

## Usage

```hcl
module "gke" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=gcp_gke/v0.1.0"

  cluster_name = "my-cluster"
  project      = "my-gcp-project"
  region       = "us-central1"
  zones        = ["us-central1-a", "us-central1-b"]

  node_pools = {
    default = {
      machine_type       = "e2-medium"
      min_count          = 1
      max_count          = 3
      initial_node_count = 1
      disk_size_gb       = 100
    }
  }

  tags = {
    environment = "production"
  }
}
```

## Requirements

| Name      | Version       |
| --------- | ------------- |
| terraform | >= 1.1, < 2.0 |
| google    | ~> 7          |

## Inputs

| Name                    | Description                                                                    | Type           | Required | Default                              |
| ----------------------- | ------------------------------------------------------------------------------ | -------------- | -------- | ------------------------------------ |
| cluster_name            | Name of the GKE cluster (max 25 characters)                                    | `string`       | Yes      | -                                    |
| project                 | GCP project ID                                                                 | `string`       | Yes      | -                                    |
| cluster_version         | Kubernetes version for the cluster                                             | `string`       | No       | `"1.31"`                             |
| region                  | GCP region                                                                     | `string`       | No       | `"us-central1"`                      |
| zones                   | GCP zones for the cluster                                                      | `list(string)` | No       | `["us-central1-a", "us-central1-b"]` |
| vpc_cidr                | CIDR block for the VPC                                                         | `string`       | No       | `"10.10.0.0/16"`                     |
| pod_cidr                | Secondary CIDR range for pods                                                  | `string`       | No       | `"192.168.16.0/20"`                  |
| services_cidr           | Secondary CIDR range for services                                              | `string`       | No       | `"192.168.0.0/20"`                   |
| node_pools              | Map of node pool configurations                                                | `map(any)`     | No       | `{}`                                 |
| tags                    | Tags to apply to resources                                                     | `map(string)`  | No       | `{}`                                 |
| enable_private_nodes    | Enable private nodes (no public IPs on nodes)                                  | `bool`         | No       | `false`                              |
| enable_private_endpoint | Enable private endpoint (control plane not publicly accessible)                | `bool`         | No       | `false`                              |
| master_ipv4_cidr_block  | CIDR block for the master network. Required when enable_private_nodes is true. | `string`       | No       | `"172.16.0.0/28"`                    |

### Node Pool Configuration

Each node pool in the `node_pools` map supports the following attributes:

| Attribute          | Description                    | Default            |
| ------------------ | ------------------------------ | ------------------ |
| machine_type       | GCE machine type               | `"e2-medium"`      |
| min_count          | Minimum number of nodes        | `0`                |
| max_count          | Maximum number of nodes        | `3`                |
| initial_node_count | Initial number of nodes        | `1`                |
| disk_size_gb       | Size of the disk in GB         | `100`              |
| disk_type          | Type of disk                   | `"pd-balanced"`    |
| image_type         | Node image type                | `"COS_CONTAINERD"` |
| preemptible        | Use preemptible VMs            | `false`            |
| spot               | Use spot VMs                   | `false`            |
| labels             | Labels to apply to nodes       | `{}`               |
| taints             | Taints to apply to nodes       | `[]`               |
| tags               | Network tags to apply to nodes | `[]`               |

## Outputs

| Name                   | Description                                |
| ---------------------- | ------------------------------------------ |
| vpc                    | VPC network details (name, id, subnetwork) |
| cluster_name           | GKE cluster name                           |
| cluster_endpoint       | GKE cluster endpoint (sensitive)           |
| cluster_ca_certificate | GKE cluster CA certificate (sensitive)     |
| node_service_account   | Node pool service account email            |

## Features Enabled

- Workload identity
- HTTP load balancing
- Horizontal pod autoscaling
- Vertical pod autoscaling
- Network policy
- Private cluster support (optional)
