mock_provider "grafana" {}

variables {
  local_directory = "tests/fixtures"
  grafana_title   = "Pause behavior"
  datasource_uids = {}
}

run "paused_and_active_rules" {
  command = plan

  assert {
    condition = one([
      for rule in grafana_rule_group.this["pause.json:0:Pause behavior"].rule : rule.is_paused
      if rule.name == "Paused rule"
    ]) == true
    error_message = "A rule with isPaused=true must remain paused in the Terraform plan."
  }

  assert {
    condition = one([
      for rule in grafana_rule_group.this["pause.json:0:Pause behavior"].rule : rule.is_paused
      if rule.name == "Active rule"
    ]) == false
    error_message = "A rule with isPaused=false must remain active."
  }

  assert {
    condition = one([
      for rule in grafana_rule_group.this["pause.json:0:Pause behavior"].rule : rule.is_paused
      if rule.name == "Default rule"
    ]) == false
    error_message = "A rule without isPaused must default to active for backward compatibility."
  }
}
