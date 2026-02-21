# Cloudflare Tunnel

This module creates a Cloudflare Zero Trust Tunnel (cloudflared) with ingress rules and optional DNS records. It provisions the tunnel, configures routing rules for hostnames to backend services, and automatically creates CNAME DNS records for each ingress rule.

## Usage

```hcl
module "cloudflare_tunnel" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=cloudflare_tunnel/v0.1.0"

  account_id = "your-cloudflare-account-id"
  zone_id    = "your-cloudflare-zone-id"
  name       = "my-tunnel"
  secret     = "your-tunnel-secret"

  ingress_rules = [
    {
      hostname = "app.example.com"
      service  = "http://localhost:8080"
    },
    {
      hostname = "api.example.com"
      service  = "https://localhost:8443"
      origin_request = {
        no_tls_verify = true
      }
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
| name | Name of the tunnel | `string` | Yes | - |
| zone_id | Cloudflare zone ID for DNS records | `string` | Yes | - |
| secret | Tunnel secret (sensitive) | `string` | Yes | - |
| ingress_rules | List of ingress rules for the tunnel | `list(object)` | No | `[]` |

### ingress_rules Object

| Attribute | Description | Type | Required | Default |
|-----------|-------------|------|----------|---------|
| hostname | Hostname for the ingress rule | `string` | Yes | - |
| service | Backend service URL | `string` | Yes | - |
| dns | Create DNS record for this hostname | `bool` | No | `true` |
| origin_request | Origin request settings | `object` | No | `null` |

### origin_request Object

| Attribute | Description | Type | Default |
|-----------|-------------|------|---------|
| http2_origin | Enable HTTP/2 to origin | `bool` | `false` |
| no_tls_verify | Disable TLS verification | `bool` | `false` |

## Outputs

| Name | Description |
|------|-------------|
| cname | The CNAME target for the tunnel (tunnel-id.cfargotunnel.com) |
