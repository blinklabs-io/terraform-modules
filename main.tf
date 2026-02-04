resource "cloudflare_ruleset" "this" {
  account_id = var.account_id
  name       = var.name
  kind       = var.kind
  phase      = var.phase
  zone_id    = data.cloudflare_zone.this.id

  rules = [{
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

data "cloudflare_zone" "this" {
  filter = {
    name = var.zone_name
  }
}
