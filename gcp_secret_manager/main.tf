locals {
  iam_members = merge([
    for id, s in var.secrets : {
      for pair in flatten([
        for role, members in s.iam_members : [for m in members : { role = role, member = m }]
      ]) : "${id}::${pair.role}::${pair.member}" => merge(pair, { secret = id })
    }
  ]...)
}

resource "google_secret_manager_secret" "this" {
  for_each = var.secrets

  project             = var.project
  secret_id           = each.key
  labels              = each.value.labels
  annotations         = each.value.annotations
  version_destroy_ttl = each.value.version_destroy_ttl
  deletion_protection = each.value.deletion_protection

  replication {
    dynamic "auto" {
      for_each = length(each.value.replication_locations) == 0 ? [1] : []
      content {
        dynamic "customer_managed_encryption" {
          for_each = each.value.kms_key_name != null ? [1] : []
          content {
            kms_key_name = each.value.kms_key_name
          }
        }
      }
    }

    dynamic "user_managed" {
      for_each = length(each.value.replication_locations) > 0 ? [1] : []
      content {
        dynamic "replicas" {
          for_each = each.value.replication_locations
          content {
            location = replicas.key
            dynamic "customer_managed_encryption" {
              for_each = replicas.value.kms_key_name != null ? [1] : []
              content {
                kms_key_name = replicas.value.kms_key_name
              }
            }
          }
        }
      }
    }
  }
}

# Additive: other members of a role on the same secret are left alone.
resource "google_secret_manager_secret_iam_member" "this" {
  for_each = local.iam_members

  project = var.project
  # The id is unknown while its entry is being replaced, and secret_id forces
  # replacement, so each grant is re-created in the same apply as its entry.
  # The entry's own name would stay the same and leave the new entry ungranted.
  secret_id = google_secret_manager_secret.this[each.value.secret].id
  role      = each.value.role
  member    = each.value.member
}
