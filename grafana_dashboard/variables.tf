variable "local_directory" {
  type        = string
  description = "Local directory containing dashboard JSON files (relative to Terraform root)."
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
