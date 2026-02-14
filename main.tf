locals {
  # Safely resolve zone_id from either direct input or zone name lookup
  zone_id_resolved = (
    var.zone_id != null
    ? var.zone_id
    : try(one(data.cloudflare_zone.this[*].id), null)
  )

  # Ensure only one is set for Cloudflare provider compatibility
  use_account_id = var.account_id != null && local.zone_id_resolved == null
  use_zone_id    = local.zone_id_resolved != null && var.account_id == null

  # Validation counter
  ids_count = (var.account_id != null ? 1 : 0) + (local.zone_id_resolved != null ? 1 : 0)

  # Extract common rules configuration to avoid duplication
  ruleset_rules = [{
    action = "redirect"
    action_parameters = {
      from_value = {
        status_code           = var.status_code
        target_url            = { value = var.target_url }
        preserve_query_string = false
      }
    }
    expression = "(http.host eq \"${var.name}\")"
    enabled    = true
  }]
}

# Standalone validation that always runs
resource "terraform_data" "validate_ids" {
  lifecycle {
    precondition {
      condition     = local.ids_count == 1
      error_message = "Exactly one of account_id or zone_id (or zone_name) must be specified. Got account_id=${var.account_id != null}, zone_id/zone_name=${local.zone_id_resolved != null}."
    }
  }

  # Ensure data sources are evaluated before validation
  depends_on = [data.cloudflare_zone.this]
}

# Account-level ruleset
resource "cloudflare_ruleset" "account" {
  count = local.use_account_id ? 1 : 0

  account_id = var.account_id
  name       = var.name
  kind       = var.kind
  phase      = var.phase

  rules = local.ruleset_rules
}

# Zone-level ruleset
resource "cloudflare_ruleset" "zone" {
  count = local.use_zone_id ? 1 : 0

  zone_id = local.zone_id_resolved
  name    = var.name
  kind    = var.kind
  phase   = var.phase

  rules = local.ruleset_rules
}

data "cloudflare_zone" "this" {
  count = var.zone_name != null ? 1 : 0
  filter = {
    name = var.zone_name
  }
}
