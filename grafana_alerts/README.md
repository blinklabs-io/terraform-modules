# grafana_alerts

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

variable "default_interval_seconds" {
  type        = number
  description = "Default interval in seconds for evaluating alerts."
  default     = 60
}
