output "service_accounts" {
  description = "Map of created service accounts"
  value = {
    for key, sa in google_service_account.this : key => {
      account_id = sa.account_id
      email      = sa.email
      name       = sa.name
      id         = sa.id
    }
  }
}

output "service_account_keys" {
  description = "Map of created service account keys"
  value = {
    for key, value in google_service_account_key.this : key => {
      private_key = value.private_key
    }
  }
  sensitive = true
}

output "custom_roles" {
  description = "Map of created custom IAM roles"
  value = {
    for key, role in google_project_iam_custom_role.this : key => {
      role_id = role.role_id
      id      = role.id
      name    = role.name
    }
  }
}

output "project_iam_bindings" {
  description = "Map of created project-level IAM member bindings"
  value = {
    for key, binding in google_project_iam_member.project_bindings : key => {
      project = binding.project
      role    = binding.role
      member  = binding.member
    }
  }
}

output "organization_iam_bindings" {
  description = "Map of created organization IAM bindings"
  value = {
    for key, binding in google_organization_iam_member.iam_member : key => {
      org_id = binding.org_id
      role   = binding.role
      member = binding.member
    }
  }
}
