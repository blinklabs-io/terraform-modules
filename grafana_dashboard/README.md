# grafana_dashboard

Requirements:
- `grafana` provider

Required variables:
- `grafana_title`
- `local_directory`

Optional variables:
```terraform
variable "datasource_uids" {
type        = map(string)
description = "Map of data source names to their respective UIDs for template substitution."
default     = {}
}
```
