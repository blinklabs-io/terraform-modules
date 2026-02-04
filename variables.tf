variable "local_directory" {
  type        = string
  description = "Local directory containing alert rule JSON files (relative to Terraform root)."
}

variable "grafana_title" {
  type        = string
  description = "Title for the Grafana folder."
}

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
