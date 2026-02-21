# cloudflare_ruleset

Terraform module to create a Cloudflare ruleset with a redirect rule. The module creates a ruleset that redirects requests matching the specified hostname to a target URL with a configurable status code.

## Usage

### Zone-level ruleset with zone_name

```hcl
module "redirect_ruleset_zone" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=cloudflare_ruleset/v0.1.0"

  zone_name   = "example.com"
  name        = "old.example.com"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"
  status_code = 301
  target_url  = "https://new.example.com"
}
```

### Zone-level ruleset with zone_id

```hcl
module "redirect_ruleset_zone_id" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=cloudflare_ruleset/v0.1.0"

  zone_id     = "your-zone-id"
  name        = "old.example.com"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"
  status_code = 301
  target_url  = "https://new.example.com"
}
```

### Account-level ruleset

```hcl
module "redirect_ruleset_account" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=cloudflare_ruleset/v0.1.0"

  account_id  = "your-cloudflare-account-id"
  name        = "old.example.com"
  kind        = "root"
  phase       = "http_request_dynamic_redirect"
  status_code = 301
  target_url  = "https://new.example.com"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.4, < 2.0 |
| cloudflare | ~> 5 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| account_id | Cloudflare account ID (use for account-level rulesets) | `string` | No* |
| zone_id | Cloudflare zone ID (use for zone-level rulesets) | `string` | No* |
| zone_name | Cloudflare zone name to look up (alternative to zone_id) | `string` | No* |
| kind | Ruleset kind (e.g., `zone`, `root`) | `string` | Yes |
| name | Ruleset name and hostname to match for redirect | `string` | Yes |
| phase | Ruleset phase (e.g., `http_request_dynamic_redirect`) | `string` | Yes |
| status_code | HTTP status code for the redirect (e.g., 301, 302) | `number` | Yes |
| target_url | Target URL to redirect to | `string` | Yes |

*Note: Exactly one of `account_id` OR (`zone_id`/`zone_name`) must be specified.

## Outputs

| Name | Description | Type |
|------|-------------|------|
| id | The ID of the created ruleset | `string` |
| name | The name of the ruleset | `string` |
| kind | The kind of the ruleset | `string` |
| phase | The phase of the ruleset | `string` |
