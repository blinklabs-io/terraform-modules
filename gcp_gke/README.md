# gcp_gke

Creates a GKE cluster with VPC, node pools, and workload identity enabled.

## Requirements

- Terraform >= 1.1, < 2.0
- Google provider ~> 6

## Required Variables

- `cluster_name` - Name of the GKE cluster
- `project` - GCP project ID

## Optional Variables

- `cluster_version` - Kubernetes version (default: "1.31")
- `region` - GCP region (default: "us-central1")
- `zones` - GCP zones (default: ["us-central1-a", "us-central1-b"])
- `vpc_cidr` - CIDR for VPC (default: "10.10.0.0/16")
- `pod_cidr` - Secondary CIDR for pods (default: "192.168.16.0/20")
- `services_cidr` - Secondary CIDR for services (default: "192.168.0.0/20")
- `node_pools` - Map of node pool configurations
- `tags` - Tags to apply

## Features Enabled

- Workload identity
- HTTP load balancing
- Horizontal pod autoscaling
- Network policy (Calico)
- Vertical pod autoscaling
