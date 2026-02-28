locals {
  # Convert list to map keyed by project_id for use with for_each.
  projects_map = { for p in var.env_vars.google.projects : p.project_id => p }

  # Merge global services with per-project services, deduplicated per project.
  all_services = {
    for pair in flatten([
      for p in var.env_vars.google.projects : [
        for s in toset(concat(var.services, p.services)) : {
          key        = "${p.project_id}/${s}"
          project_id = google_project.this[p.project_id].project_id
          service    = s
        }
      ]
      ]) : pair.key => {
      project_id = pair.project_id
      service    = pair.service
    }
  }

  # Key of the project designated as the admin/management project for the terraform runner SA.
  # Returns null if no admin project is set (valid when enable_terraform_runner = false).
  admin_project_key = one([
    for p in var.env_vars.google.projects : p.project_id if p.admin
  ])
}

resource "google_project" "this" {
  provider            = google
  for_each            = local.projects_map
  name                = coalesce(each.value.display_name, each.value.project_id)
  project_id          = each.value.project_id
  org_id              = each.value.folder_id == null && var.gcp_folder_id == null ? var.gcp_organization_id : null
  folder_id           = each.value.folder_id != null ? each.value.folder_id : var.gcp_folder_id
  auto_create_network = each.value.network
  deletion_policy     = var.deletion_policy
  billing_account     = each.value.billing_account != null ? each.value.billing_account : var.gcp_billing_account

  # Required for the project to display in any list of Firebase projects.
  labels = each.value.firebase ? { firebase = "enabled" } : {}

  timeouts {
    create = var.project_create_timeout
    update = var.project_update_timeout
    delete = var.project_delete_timeout
  }

  lifecycle {
    precondition {
      condition     = var.gcp_organization_id != null || var.gcp_folder_id != null || each.value.folder_id != null
      error_message = "Each project requires an org or folder. Set gcp_organization_id, gcp_folder_id, or a per-project folder_id."
    }
  }
}

# Enable services per project
resource "google_project_service" "this" {
  for_each = local.all_services
  project  = each.value.project_id
  service  = each.value.service

  provider = google

  disable_on_destroy = var.service_disable_on_destroy

  timeouts {
    create = var.service_create_timeout
    update = var.service_update_timeout
  }
}

# Terraform runner access (optional)

resource "google_service_account" "terraform_runner" {
  for_each     = var.enable_terraform_runner ? { runner = true } : {}
  provider     = google
  account_id   = var.terraform_runner_account_id
  display_name = "Terraform runner"
  project      = local.admin_project_key != null ? google_project.this[local.admin_project_key].project_id : ""

  lifecycle {
    precondition {
      condition     = local.admin_project_key != null
      error_message = "When enable_terraform_runner is true, exactly one project must have admin = true."
    }
    precondition {
      condition     = var.gcp_organization_id != null
      error_message = "gcp_organization_id is required when enable_terraform_runner is true for organization-level IAM bindings."
    }
  }
}

# Iterate over the SA map directly — if SA doesn't exist the map is empty and no key is created.
resource "google_service_account_key" "terraform_runner" {
  for_each           = var.export_terraform_runner_key ? google_service_account.terraform_runner : {}
  provider           = google
  service_account_id = each.value.name
}

resource "google_organization_iam_member" "terraform_runner" {
  for_each = var.enable_terraform_runner ? { for role in var.terraform_runner_roles : role => role } : {}
  provider = google
  role     = "roles/${each.key}"
  org_id   = var.gcp_organization_id
  member   = "serviceAccount:${one(values(google_service_account.terraform_runner)).email}"
}
