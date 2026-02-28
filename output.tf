output "projects" {
  value = {
    for k, p in google_project.this : k => {
      project_id     = p.project_id
      project_number = p.number
      name           = p.name
    }
  }
  description = "Map of created GCP projects with their ID, number, and display name"
}

output "services" {
  value = {
    for project_id in keys(google_project.this) :
    project_id => [
      for pair in local.all_services :
      pair.service if pair.project_id == project_id
    ]
  }
  description = "Map of project ID to list of enabled Google services"
}

output "terraform_runner_private_key" {
  value       = try(one(values(google_service_account_key.terraform_runner)).private_key, null)
  sensitive   = true
  description = "Base64-encoded private key for the terraform-runner service account. Only emitted when export_terraform_runner_key = true (null otherwise)."
}

output "terraform_runner_email" {
  value       = try(one(values(google_service_account.terraform_runner)).email, null)
  description = "Email of terraform-runner service account (null if disabled)"
}
