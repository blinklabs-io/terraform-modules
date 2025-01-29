# cloudflare_tunnel

Requirements:
- `cloudflare` provider

Required variables:
- `account_id`
- `name`
- `secret`
- `zone_id`

Optional variables:
```
variable "ingress_rules" {
  type = list(object({
    hostname = string
    service  = string
    dns      = optional(bool, true)
    origin_request = optional(object({
      http2_origin  = optional(bool, false)
      no_tls_verify = optional(bool, false)
    }))
  }))
  default = []
}
```
