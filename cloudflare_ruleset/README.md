# cloudflare_ruleset

Terraform module to create a Cloudflare ruleset with a redirect rule. The module creates a ruleset that redirects requests matching the specified hostname to a target URL with a configurable status code.

## Usage

```hcl
module "redirect_ruleset" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git//cloudflare_ruleset?ref=cloudflare_ruleset/v0.1.0"

  account_id  = "your-cloudflare-account-id"
  zone_name   = "example.com"
  name        = "old.example.com"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"
  status_code = 301
  target_url  = "https://new.example.com"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1, < 2.0 |
| cloudflare | ~> 5 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| account_id | Cloudflare account ID | `string` | Yes |
| kind | Ruleset kind (e.g., `zone`, `root`) | `string` | Yes |
| name | Ruleset name and hostname to match for redirect | `string` | Yes |
| phase | Ruleset phase (e.g., `http_request_dynamic_redirect`) | `string` | Yes |
| status_code | HTTP status code for the redirect (e.g., 301, 302) | `number` | Yes |
| target_url | Target URL to redirect to | `string` | Yes |
| zone_name | Cloudflare zone name to look up | `string` | Yes |

## Outputs

This module does not export any outputs.
