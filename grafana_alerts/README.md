# Grafana Alerts

Terraform module for creating Grafana alert rules from JSON files. Creates a Grafana folder and populates it with rule groups parsed from local JSON alert definition files.

## Usage

```hcl
module "grafana_alerts" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git//grafana_alerts?ref=grafana_alerts/v0.1.0"

  grafana_title   = "My Alerts"
  local_directory = "alerts"
  datasource_uids = {
    prometheus = "abc123"
    loki       = "def456"
  }
  default_interval_seconds = 60
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1, < 2.0 |
| grafana | ~> 3 |

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| local_directory | Local directory containing alert rule JSON files (relative to Terraform root). | `string` | Yes | - |
| grafana_title | Title for the Grafana folder. | `string` | Yes | - |
| datasource_uids | Map of data source names to their respective UIDs for template substitution. | `map(string)` | No | `{}` |
| default_interval_seconds | Default interval in seconds for evaluating alerts. | `number` | No | `60` |

## Outputs

| Name | Description |
|------|-------------|
| folder_uid | The UID of the created Grafana folder |
| rule_group_ids | Map of rule group file names to their IDs |
