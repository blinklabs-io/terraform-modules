# Cloudflare Load Balancer

Terraform module that creates a Cloudflare Load Balancer with optional pool and health monitor configuration.

## Usage

```hcl
module "cloudflare_lb" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=cloudflare_lb/v0.1.0"

  name       = "app"
  account_id = "your-cloudflare-account-id"
  zone_name  = "example.com"

  origins = [
    {
      name    = "origin-1"
      address = "192.168.1.1"
    },
    {
      name    = "origin-2"
      address = "192.168.1.2"
    }
  ]

  monitor_enabled = true
  monitor_type    = "http"
  monitor_path    = "/health"
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
| name | Name of the load balancer | `string` | Yes | - |
| account_id | Cloudflare account ID | `string` | Yes | - |
| zone_name | DNS zone name for the load balancer | `string` | Yes | - |
| origins | List of origin servers with name and address | `list(object({ name = string, address = string }))` | No | `[]` |
| default_pool_ids | List of default pool IDs (creates pool if null) | `any` | No | `null` |
| fallback_pool_id | Fallback pool ID (uses created pool if null) | `any` | No | `null` |
| load_balancer_monitor_id | Existing monitor ID (creates monitor if null) | `any` | No | `null` |
| monitor_enabled | Enable health monitoring | `bool` | No | `true` |
| monitor_type | Monitor protocol type | `string` | No | `"http"` |
| monitor_path | Path to monitor for health checks | `string` | No | `"/"` |
| monitor_method | HTTP method for health checks | `string` | No | `"GET"` |
| monitor_interval | Interval between health checks in seconds | `number` | No | `60` |
| monitor_timeout | Timeout for health check requests in seconds | `number` | No | `5` |
| monitor_retries | Number of retries before marking origin unhealthy | `number` | No | `3` |
| monitor_expected_codes | Expected HTTP response codes | `string` | No | `"200"` |
| monitor_headers | HTTP headers to send with health check requests | `map(list(string))` | No | `{}` |

## Outputs

This module does not have any outputs.
