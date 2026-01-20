# terraform-modules

A highly-opinionated set of Terraform modules for AWS, GCP, Cloudflare, and Grafana infrastructure at Blink Labs.

## AWS

- `aws_acm` manages ACM certificates with DNS validation using Route53
- `aws_eks` creates an EKS cluster with VPC, addons, and IAM roles
- `aws_iam` manages IAM users, access keys, and policies
- `aws_kms` manages KMS keys with administrators and aliases
- `aws_s3` manages S3 buckets with ACLs, policies, and ownership controls

## GCP

- `gcp_gke` creates a GKE cluster with VPC, node pools, and workload identity
- `gcp_iam` manages GCP IAM resources including service accounts, custom roles, and workload identity bindings

## Cloudflare

- `cloudflare_lb` configures a Cloudflare Load Balancer with pools and monitors
- `cloudflare_page` configures a Cloudflare Pages project attached to GitHub
- `cloudflare_ruleset` manages Cloudflare Rulesets for zones or accounts
- `cloudflare_tunnel` sets up Cloudflare Tunnels with ingress rules
- `cloudflare_zone` configures a Cloudflare Zone

## Grafana

- `grafana_alerts` manages Grafana alert rules from local files
- `grafana_dashboard` manages Grafana dashboards from local files
