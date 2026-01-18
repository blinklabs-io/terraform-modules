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
