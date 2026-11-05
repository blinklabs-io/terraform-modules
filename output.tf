output "folder_uid" {
  description = "The UID of the created Grafana folder"
  value       = grafana_folder.this.uid
}

output "rule_group_ids" {
  description = "Map of rule group keys to their IDs"
  value       = { for k, v in grafana_rule_group.this : k => v.id }
}
