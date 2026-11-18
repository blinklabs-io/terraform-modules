output "secret_ids" {
  description = "Map of secret key to secret ID"
  value       = { for k, s in google_secret_manager_secret.this : k => s.secret_id }
}

output "secret_names" {
  description = "Map of secret key to full resource name (projects/<project>/secrets/<id>)"
  value       = { for k, s in google_secret_manager_secret.this : k => s.name }
}
