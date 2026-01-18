resource "cloudflare_zero_trust_tunnel_cloudflared" "this" {
  account_id    = var.account_id
  name          = var.name
  tunnel_secret = var.secret
  config_src    = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "this" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id

  config = {
    ingress = concat(
      [for r in var.ingress_rules : merge(
        {
          hostname = r.hostname
          service  = r.service
        },
        r.origin_request != null ? {
          origin_request = {
            http2_origin  = r.origin_request.http2_origin
            no_tls_verify = r.origin_request.no_tls_verify
          }
        } : {}
      )],
      [{ service = "http_status:404" }]
    )
  }
}

resource "cloudflare_dns_record" "this" {
  for_each = { for r in var.ingress_rules : r.hostname => r if r.dns }

  zone_id = var.zone_id
  name    = split(".", each.value.hostname)[0]
  content = "${cloudflare_zero_trust_tunnel_cloudflared.this.id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}
