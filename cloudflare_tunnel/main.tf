resource "cloudflare_zero_trust_tunnel_cloudflared" "this" {
  account_id    = var.account_id
  name          = var.name
  tunnel_secret = var.secret
  config_src    = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "this" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id

  config {
    dynamic "ingress_rule" {
      for_each = { for r in var.ingress_rules : r.hostname => r }
      content {
        service  = ingress_rule.value.service
        hostname = ingress_rule.value.hostname

        dynamic "origin_request" {
          for_each = { for o in((lookup(ingress_rule.value, "origin_request", null) != null) ? [{ "name" : "enabled", "http2_origin" : ingress_rule.value.origin_request.http2_origin, "no_tls_verify" : ingress_rule.value.origin_request.no_tls_verify }] : []) : o.name => o }
          content {
            http2_origin  = try(origin_request.value.http2_origin, false)
            no_tls_verify = try(origin_request.value.no_tls_verify, false)
          }
        }
      }
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_dns_record" "this" {
  for_each = { for r in var.ingress_rules : r.hostname => r if r.dns }

  zone_id = var.zone_id
  name    = split(".", each.value.hostname)[0]
  content = cloudflare_zero_trust_tunnel_cloudflared.this.cname
  type    = "CNAME"
  proxied = true
}
