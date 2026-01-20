resource "google_project_iam_custom_role" "this" {
  for_each = { for r in var.custom_roles : "${coalesce(r.project, var.project)}::${r.role_id}" => r }

  role_id     = each.value.role_id
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  project     = coalesce(each.value.project, var.project)
}
