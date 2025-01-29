locals {
  monitor_id = var.load_balancer_monitor_id != null ? var.load_balancer_monitor_id : cloudflare_load_balancer_monitor.this["enabled"].id
}

resource "cloudflare_load_balancer" "this" {
  name             = "${var.name}.${var.zone_name}"
  default_pool_ids = var.default_pool_ids != null ? var.default_pool_ids : [cloudflare_load_balancer_pool.this["enabled"].id]
  fallback_pool_id = var.fallback_pool_id != null ? var.fallback_pool_id : cloudflare_load_balancer_pool.this["enabled"].id
  proxied          = true
  zone_id          = data.cloudflare_zone.this.id
}

resource "cloudflare_load_balancer_pool" "this" {
  for_each = toset([for p in ["enabled"] : p if var.default_pool_ids == null])

  account_id = var.account_id
  name       = var.name
  monitor    = var.monitor_enabled ? local.monitor_id : null

  dynamic "origins" {
    for_each = { for o in var.origins : o.name => o }
    content {
      name    = origins.value.name
      address = origins.value.address
    }
  }
}

resource "cloudflare_load_balancer_monitor" "this" {
  for_each = toset([for m in ["enabled"] : m if var.monitor_enabled && var.load_balancer_monitor_id == null])

  account_id     = var.account_id
  description    = var.name
  type           = var.monitor_type
  path           = var.monitor_path
  interval       = var.monitor_interval
  method         = var.monitor_method
  timeout        = var.monitor_timeout
  retries        = var.monitor_retries
  expected_codes = var.monitor_expected_codes

  dynamic "header" {
    for_each = { for h in var.monitor_headers : h.header => h }
    content {
      header = header.value.header
      values = header.value.values
    }
  }
}

data "cloudflare_zone" "this" {
  name = var.zone_name
}
