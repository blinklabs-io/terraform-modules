# Cloudflare Zone

Terraform module for managing a Cloudflare zone with opinionated security settings and DNS records. Creates a zone with HTTPS enforcement, TLS 1.2+, HSTS headers, and optimized caching settings. Supports A, CNAME, MX, and TXT DNS records.

## Usage

```hcl
module "cloudflare_zone" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=cloudflare_zone/v0.1.0"

  account_id = "your-cloudflare-account-id"
  zone_name  = "example.com"
  plan       = "free"

  a_records = [
    {
      name        = "www"
      record_name = "www"
      content     = "192.0.2.1"
      proxied     = true
    }
  ]

  cname_records = [
    {
      name        = "blog"
      record_name = "blog"
      content     = "example.netlify.app"
      proxied     = true
    }
  ]

  mx_records = [
    {
      value    = "mail.example.com"
      priority = 10
    }
  ]

  txt_records = [
    {
      name        = "spf"
      record_name = "@"
      content     = "v=spf1 include:_spf.example.com ~all"
    }
  ]
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
| zone_name | Domain name for the zone | `string` | Yes | - |
| plan | Cloudflare plan type (affects available features) | `string` | No | `"free"` |
| a_records | List of A DNS records | `list(object({name=string, record_name=string, content=string, proxied=optional(bool, true)}))` | No | `[]` |
| cname_records | List of CNAME DNS records | `list(object({name=string, record_name=string, content=string, proxied=optional(bool, true)}))` | No | `[]` |
| mx_records | List of MX DNS records | `list(object({value=string, priority=number}))` | No | `[]` |
| txt_records | List of TXT DNS records | `list(object({name=string, record_name=string, content=string}))` | No | `[]` |

## Outputs

| Name | Description |
|------|-------------|
| zone_id | The ID of the created Cloudflare zone |
