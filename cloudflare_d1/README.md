# Cloudflare D1

Terraform module for managing a Cloudflare D1 serverless SQL database.

## Usage

```hcl
module "cloudflare_d1" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=cloudflare_d1/v0.1.0"

  account_id = "your-cloudflare-account-id"
  name       = "tosidrop-db"
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
| name | Name of the D1 database | `string` | Yes | - |
| primary_location_hint | Primary location hint for the database (e.g. `wnam`, `enam`, `weur`, `eeur`, `apac`, `oc`) | `string` | No | `null` |
| read_replication_mode | Read replication mode (`auto` or `disabled`) | `string` | No | `null` |

## Outputs

| Name | Description |
|------|-------------|
| database_id | The ID of the D1 database |
| name | The name of the D1 database |
