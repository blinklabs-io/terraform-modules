resource "google_iam_workload_identity_pool" "this" {
  for_each = { for p in var.workload_identity_pools : "${coalesce(p.project, var.project)}::${p.pool_id}" => p }

  project                   = coalesce(each.value.project, var.project)
  workload_identity_pool_id = each.value.pool_id
  display_name              = each.value.display_name
  description               = each.value.description
  disabled                  = each.value.disabled
}

resource "google_iam_workload_identity_pool_provider" "this" {
  for_each = merge([
    for p in var.workload_identity_pools : {
      for pr in p.providers :
      "${coalesce(p.project, var.project)}::${p.pool_id}::${pr.provider_id}" => merge(pr, {
        pool_key = "${coalesce(p.project, var.project)}::${p.pool_id}"
      })
    }
  ]...)

  project                            = google_iam_workload_identity_pool.this[each.value.pool_key].project
  workload_identity_pool_id          = google_iam_workload_identity_pool.this[each.value.pool_key].workload_identity_pool_id
  workload_identity_pool_provider_id = each.value.provider_id
  display_name                       = each.value.display_name
  description                        = each.value.description
  attribute_mapping                  = each.value.attribute_mapping
  attribute_condition                = each.value.attribute_condition

  oidc {
    issuer_uri        = each.value.issuer_uri
    allowed_audiences = each.value.allowed_audiences
  }
}

resource "google_service_account_iam_member" "workload_identity_pool" {
  for_each = {
    for b in var.workload_identity_pool_bindings :
    "${coalesce(b.project, var.project)}::${coalesce(b.service_account_id, b.service_account_email)}::${b.pool_id}::${b.attribute}::${b.value}" => b
  }

  service_account_id = (
    each.value.service_account_email != null
    ? "projects/${coalesce(each.value.project, var.project)}/serviceAccounts/${each.value.service_account_email}"
    : google_service_account.this["${coalesce(each.value.project, var.project)}::${each.value.service_account_id}"].name
  )
  role = "roles/iam.workloadIdentityUser"
  # A subject names one principal; any other attribute names a principal set.
  member = (
    each.value.attribute == "subject"
    ? "principal://iam.googleapis.com/${google_iam_workload_identity_pool.this["${coalesce(each.value.project, var.project)}::${each.value.pool_id}"].name}/subject/${each.value.value}"
    : "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.this["${coalesce(each.value.project, var.project)}::${each.value.pool_id}"].name}/${each.value.attribute}/${each.value.value}"
  )
}
