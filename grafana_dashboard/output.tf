output "folder_uid" {
  description = "The UID of the created Grafana folder"
  value       = grafana_folder.this.uid
}

output "dashboard_ids" {
  description = "Map of dashboard file names to their IDs"
  value       = { for k, v in grafana_dashboard.this : k => v.id }
}
