# Grafana Alerts

Terraform module for creating Grafana alert rules from JSON files. Creates a Grafana folder and deploys rule groups parsed from local JSON alert definition files.

## Usage

```hcl
module "grafana_alerts" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=grafana_alerts/v0.1.0"

  grafana_title   = "My Alerts"
  local_directory = "alerts"
  datasource_uids = {
    prometheus = "abc123"
    loki       = "def456"
  }
  default_interval_seconds = 60
}
```

### Templating

Alert JSON files should use `${datasource_uid_map["<name>"]}` for datasource UID substitution.

Grafana built-in variables (e.g., `${__from}`, `${__to}`, `${__interval}`) must be escaped as `$${__from}` in JSON files to prevent Terraform's `templatefile` from interpreting them.

### JSON structure

Each JSON file may contain multiple groups. Each group becomes a separate `grafana_rule_group` resource with its own name and optional interval:

```json
{
  "groups": [
    {
      "name": "HighCPU",
      "interval": 120,
      "rules": [...]
    },
    {
      "name": "DiskFull",
      "rules": [...]
    }
  ]
}
```

If a group omits `interval`, it falls back to `default_interval_seconds`.

### Notification settings

Rules may optionally include a `notification_settings` object to configure simplified notification routing. This requires **Grafana >= 10.4** with the `alertingSimplifiedRouting` feature flag enabled.

Supported fields:

| Field | Description | Required |
|-------|-------------|----------|
| `receiver` | Contact point name | Yes |
| `group_by` | Labels to group alerts by | No |
| `group_interval` | Interval between grouped notifications | No |
| `group_wait` | Wait time before sending first notification | No |
| `repeat_interval` | Interval for re-sending notifications | No |
| `mute_timings` | List of mute timing names | No |

If a rule omits `notification_settings`, no routing override is applied and Grafana's default notification policy is used.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3, < 2.0 |
| grafana | ~> 4 |

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| local_directory | Local directory containing alert rule JSON files (relative to Terraform root). | `string` | Yes | - |
| grafana_title | Title for the Grafana folder. | `string` | Yes | - |
| datasource_uids | Map of data source names to their respective UIDs for template substitution. | `map(string)` | Yes | - |
| default_interval_seconds | Default interval in seconds for evaluating alerts. | `number` | No | `60` |

## Outputs

| Name | Description |
|------|-------------|
| folder_uid | The UID of the created Grafana folder |
| rule_group_ids | Map of rule group keys to their IDs |
