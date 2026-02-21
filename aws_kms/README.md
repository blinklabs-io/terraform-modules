# AWS KMS

This module creates AWS KMS keys with automatic key rotation enabled. It wraps the `terraform-aws-modules/kms/aws` community module and provides a simplified interface for key management.

## Usage

```hcl
module "kms" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=aws_kms/v0.1.0"

  description = "My application encryption key"
  aliases     = ["alias/my-app-key"]
  admins      = ["arn:aws:iam::123456789012:role/admin"]
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
| description | KMS key description | `string` | Yes | - |
| admins | List of KMS key admins | `list(string)` | No | `[]` |
| aliases | List of aliases for KMS key | `list(string)` | No | `[]` |

## Outputs

This module does not define any outputs.
