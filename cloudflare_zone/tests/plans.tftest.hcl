mock_provider "cloudflare" {}

variables {
  account_id = "00000000000000000000000000000000"
  zone_name  = "example.com"
}

run "free_settings" {
  command = plan

  variables {
    plan = "free"
  }

  assert {
    condition     = !contains(keys(cloudflare_zone_setting.this), "h2_prioritization")
    error_message = "Free zones must not manage paid Enhanced HTTP/2 Prioritization."
  }
}

run "paid_settings" {
  command = plan

  variables {
    plan = "pro"
  }

  assert {
    condition     = cloudflare_zone_setting.this["h2_prioritization"].value == "on"
    error_message = "Paid zones must retain Enhanced HTTP/2 Prioritization."
  }
}
