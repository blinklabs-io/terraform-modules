# gcp_iam

Manages GCP IAM resources including service accounts, custom roles, and workload identity bindings.

## Requirements

- Terraform >= 1.1, < 2.0
- Google provider ~> 6

## Required Variables

- `project` - Default GCP project ID

## Optional Variables

- `service_accounts` - List of service accounts to manage
- `custom_roles` - List of custom IAM roles to manage
- `workload_identity_bindings` - List of workload identity bindings
