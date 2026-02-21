# AWS EKS

Terraform module for deploying an Amazon EKS cluster with VPC, managed node groups, and IAM roles for service accounts (IRSA).

## Features

- Creates a VPC with public and private subnets
- Deploys an EKS cluster with managed node groups
- Configures essential EKS addons (CoreDNS, kube-proxy, VPC CNI, EBS CSI driver, Pod Identity Agent)
- Sets up IRSA for EBS CSI driver and AWS Load Balancer Controller
- Enables IRSA (IAM Roles for Service Accounts)
- Encrypts node root volumes with AWS KMS

## Usage

```hcl
module "eks" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=aws_eks/v0.1.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.32"
  cidr            = "10.10.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1d"]
  public_subnets  = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]
  private_subnets = ["10.10.48.0/20"]

  node_groups = {
    default = {
      ami_type      = "AL2023_ARM_64_STANDARD"
      instance_type = "t4g.medium"
      min_size      = 0
      max_size      = 2
      desired_size  = 1
    }
  }

  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1, < 2.0 |
| aws | No version constraint |

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| cluster_name | Name of the EKS cluster | `string` | Yes | - |
| cluster_version | Kubernetes version for the EKS cluster | `string` | No | `"1.32"` |
| cidr | CIDR block for the VPC | `string` | No | `"10.10.0.0/16"` |
| azs | List of availability zones | `list(string)` | No | `["us-east-1a", "us-east-1b", "us-east-1d"]` |
| private_subnets | List of private subnet CIDR blocks | `list(string)` | No | `["10.10.48.0/20"]` |
| public_subnets | List of public subnet CIDR blocks | `list(string)` | No | `["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]` |
| tags | Tags to apply to all resources | `any` | No | `[]` |
| node_groups | Map of EKS managed node group configurations | `any` | No | `{}` |

### Node Group Configuration

Each node group in the `node_groups` map supports the following attributes:

| Attribute | Description | Default |
|-----------|-------------|---------|
| ami_type | AMI type for the node group | `"AL2023_ARM_64_STANDARD"` |
| instance_type | EC2 instance type | `"t4g.medium"` |
| min_size | Minimum number of nodes | `0` |
| max_size | Maximum number of nodes | `2` |
| desired_size | Desired number of nodes | `0` |
| kubelet_extra_args | Extra arguments for kubelet | `""` |
| autoscaling_group_tags | Tags for the autoscaling group | `{}` |
| metadata_options | Instance metadata options | `null` |
| tags | Tags for the node group | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| vpc | VPC module outputs (vpc_id, public_subnets, private_subnets, etc.) |
