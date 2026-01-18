resource "cloudflare_zone" "this" {
  account = {
    id = var.account_id
  }
  name = var.zone_name
  type = "full"
}

locals {
  zone_settings = {
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    brotli                   = "on"
    browser_cache_ttl        = var.plan == "free" ? 300 : 14400
    cache_level              = var.plan == "free" ? "basic" : "aggressive"
    early_hints              = "on"
    h2_prioritization        = "on"
    http3                    = "on"
    min_tls_version          = "1.2"
    mirage                   = var.plan == "free" ? null : "on"
    opportunistic_encryption = "on"
    rocket_loader            = "on"
    ssl                      = "strict"
    tls_1_3                  = "zrt"
    webp                     = var.plan == "free" ? null : "on"
    websockets               = "on"
  }
}

resource "cloudflare_zone_setting" "this" {
  for_each = { for k, v in local.zone_settings : k => v if v != null }

  zone_id    = cloudflare_zone.this.id
  setting_id = each.key
  value      = each.value
}

resource "cloudflare_zone_setting" "security_header" {
  zone_id    = cloudflare_zone.this.id
  setting_id = "security_header"
  value = {
    strict_transport_security = {
      enabled            = true
      preload            = true
      max_age            = 31536000
      include_subdomains = true
    }
  }
}

resource "cloudflare_dns_record" "a" {
  for_each = { for a in var.a_records : a.name => a }

  zone_id = cloudflare_zone.this.id
  name    = try(each.value.record_name, each.value.name)
  content = each.value.content
  type    = "A"
  ttl     = each.value.proxied ? 1 : 30
  proxied = each.value.proxied
}

resource "cloudflare_dns_record" "cname" {
  for_each = { for c in var.cname_records : c.name => c }

  zone_id = cloudflare_zone.this.id
  name    = try(each.value.record_name, each.value.name)
  content = each.value.content
  type    = "CNAME"
  ttl     = each.value.proxied ? 1 : 30
  proxied = each.value.proxied
}

resource "cloudflare_dns_record" "mx" {
  for_each = { for m in var.mx_records : m.value => m }

  zone_id  = cloudflare_zone.this.id
  name     = "@"
  content  = each.value.value
  priority = each.value.priority
  type     = "MX"
  ttl      = 30
}

resource "cloudflare_dns_record" "txt" {
  for_each = { for t in var.txt_records : t.name => t }

  zone_id = cloudflare_zone.this.id
  name    = try(each.value.record_name, each.value.name)
  content = each.value.content
  type    = "TXT"
  ttl     = 30
}
