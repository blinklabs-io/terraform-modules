output "uids" {
  value       = { for _, ds in grafana_data_source.this : ds.name => ds.uid }
  description = "Map of data source names to their respective UIDs."
}
