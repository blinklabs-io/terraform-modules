resource "google_service_account" "this" {
  for_each = { for sa in var.service_accounts : "${coalesce(sa.project, var.project)}::${sa.account_id}" => sa }

  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
  project      = coalesce(each.value.project, var.project)
}

resource "google_service_account_key" "this" {
  for_each = { for sa in var.service_accounts : "${coalesce(sa.project, var.project)}::${sa.account_id}" => sa
  if sa.create_key == true }

  service_account_id = google_service_account.this[each.key].name
}

resource "google_project_iam_member" "service_account" {
  for_each = merge({}, flatten([
    for sa in var.service_accounts : [
      for binding in sa.iam_bindings : {
        "${coalesce(binding.project, sa.project, var.project)}::${sa.account_id}::${binding.role}" = {
          sa_key  = "${coalesce(sa.project, var.project)}::${sa.account_id}"
          role    = binding.role
          project = coalesce(binding.project, sa.project, var.project)
        }
      }
    ]
  ])...)

  project = each.value.project
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.this[each.value.sa_key].email}"
}

resource "google_project_iam_member" "project_bindings" {
  for_each = {
    for pb in var.project_iam_members :
    "${pb.project}::${pb.role}::${pb.member}" => pb
  }

  project = each.value.project
  role    = each.value.role
  member  = each.value.member
}

resource "google_organization_iam_member" "iam_member" {
  for_each = merge([
    for binding in var.organization_iam_bindings : {
      for member in binding.members :
      "${binding.role}::${member}" => {
        role   = binding.role
        member = member
      }
    }
  ]...)

  org_id = var.organization_id
  role   = each.value.role
  member = each.value.member

  lifecycle {
    precondition {
      condition     = var.organization_id != null
      error_message = "organization_id must be specified when organization_iam_bindings is non-empty."
    }
  }
}
