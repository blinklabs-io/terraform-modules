# Cloudflare R2

Terraform module for managing a Cloudflare R2 object storage bucket.

## Usage

```hcl
module "cloudflare_r2" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=cloudflare_r2/v0.1.0"

  account_id = "your-cloudflare-account-id"
  name       = "tosidrop-bucket"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1, < 2.0 |
| cloudflare | ~> 5 |

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| account_id | Cloudflare account ID | `string` | Yes | - |
| name | Name of the R2 bucket | `string` | Yes | - |
| location | Location hint for the bucket (e.g. `apac`, `eeur`, `enam`, `weur`, `wnam`) | `string` | No | `null` |
| storage_class | Storage class for the bucket. One of `Standard` or `InfrequentAccess` | `string` | No | `"Standard"` |

## Outputs

| Name | Description |
|------|-------------|
| name | The name of the R2 bucket |
| location | The location of the R2 bucket |
| storage_class | The storage class of the R2 bucket |
