# Grafana Dashboard

Creates a Grafana folder and deploys dashboards from local JSON files with optional datasource UID templating.

## Usage

```hcl
module "grafana_dashboard" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=grafana_dashboard/v0.1.0"

  grafana_title   = "My Dashboards"
  local_directory = "dashboards"
  datasource_uids = {
    prometheus = "abc123"
    loki       = "def456"
  }
}
```

Dashboard JSON files should use `${datasource_uid_map["<name>"]}` for datasource UID templating. When `datasource_uids` is empty, files are loaded as plain JSON without templating.

Grafana built-in variables (e.g., `${__from}`, `${__to}`, `${__interval}`) must be escaped as `$${__from}` in JSON files to prevent Terraform's `templatefile` from interpreting them.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3, < 2.0 |
| grafana | ~> 4 |

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| local_directory | Local directory containing dashboard JSON files (relative to Terraform root) | `string` | Yes | - |
| grafana_title | Title for the Grafana folder | `string` | Yes | - |
| datasource_uids | Map of data source names to their respective UIDs for template substitution | `map(string)` | No | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| folder_uid | The UID of the created Grafana folder |
| dashboard_ids | Map of dashboard file names to their IDs |
