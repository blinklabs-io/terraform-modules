resource "google_service_account_iam_member" "workload_identity" {
  for_each = { for wi in var.workload_identity_bindings : "${coalesce(wi.project, var.project)}::${coalesce(wi.service_account_id, wi.service_account_email)}::${wi.namespace}::${wi.k8s_service_account}" => wi }

  service_account_id = (
    each.value.service_account_email != null
    ? "projects/${coalesce(each.value.project, var.project)}/serviceAccounts/${each.value.service_account_email}"
    : google_service_account.this["${coalesce(each.value.project, var.project)}::${each.value.service_account_id}"].name
  )
  role   = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${coalesce(each.value.project, var.project)}.svc.id.goog[${each.value.namespace}/${each.value.k8s_service_account}]"
}
