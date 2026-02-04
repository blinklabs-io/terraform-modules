locals {
  monitor_id = var.load_balancer_monitor_id != null ? var.load_balancer_monitor_id : cloudflare_load_balancer_monitor.this["enabled"].id
}

resource "cloudflare_load_balancer" "this" {
  name          = "${var.name}.${var.zone_name}"
  default_pools = var.default_pool_ids != null ? var.default_pool_ids : [cloudflare_load_balancer_pool.this["enabled"].id]
  fallback_pool = var.fallback_pool_id != null ? var.fallback_pool_id : cloudflare_load_balancer_pool.this["enabled"].id
  proxied       = true
  zone_id       = data.cloudflare_zone.this.id
}

resource "cloudflare_load_balancer_pool" "this" {
  for_each = toset([for p in ["enabled"] : p if var.default_pool_ids == null])

  account_id = var.account_id
  name       = var.name
  monitor    = var.monitor_enabled ? local.monitor_id : null
  origins    = [for o in var.origins : { name = o.name, address = o.address }]
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
  header         = var.monitor_headers
}

data "cloudflare_zone" "this" {
  filter = {
    name = var.zone_name
  }
}
