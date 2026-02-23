variable "local_directory" {
  type        = string
  description = "Local directory containing alert JSON files (relative to Terraform root)."
}

variable "grafana_title" {
  type        = string
  description = "Title for the Grafana folder."
}

variable "default_interval_seconds" {
  type        = number
  default     = 60
  description = "Default interval in seconds for evaluating alerts."

  validation {
    condition     = var.default_interval_seconds >= 10
    error_message = "Interval must be at least 10 seconds."
  }
}

variable "datasource_uids" {
  type        = map(string)
  description = "Map of data source names to their respective UIDs for template substitution."
}
