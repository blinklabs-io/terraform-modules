locals {
  # Keyed by key, role, and member so that adding or removing one member
  # leaves the other bindings untouched.
  iam_members = {
    for binding in flatten([
      for key_name, key in var.keys : [
        for role, members in key.iam_members : [
          for member in distinct(members) : {
            key_name = key_name
            role     = role
            member   = member
          }
        ]
      ]
    ]) : "${binding.key_name}|${binding.role}|${binding.member}" => binding
  }
}

resource "google_kms_key_ring" "this" {
  project  = var.project
  name     = var.name
  location = var.location
}

resource "google_kms_crypto_key" "this" {
  for_each = var.keys

  name                       = each.key
  key_ring                   = google_kms_key_ring.this.id
  purpose                    = each.value.purpose
  rotation_period            = each.value.rotation_period
  destroy_scheduled_duration = each.value.destroy_scheduled_duration
  labels                     = each.value.labels
  deletion_policy            = var.deletion_policy
  crypto_key_backend         = each.value.crypto_key_backend

  # Cloud KMS cannot create an external key version without its external key
  # URI or path, so EXTERNAL and EXTERNAL_VPC keys are created empty.
  skip_initial_version_creation = each.value.version_template == null ? false : contains(["EXTERNAL", "EXTERNAL_VPC"], each.value.version_template.protection_level)

  dynamic "version_template" {
    for_each = each.value.version_template == null ? [] : [each.value.version_template]

    content {
      algorithm        = version_template.value.algorithm
      protection_level = version_template.value.protection_level
    }
  }
}

resource "google_kms_crypto_key_iam_member" "this" {
  for_each = local.iam_members

  crypto_key_id = google_kms_crypto_key.this[each.value.key_name].id
  role          = each.value.role
  member        = each.value.member
}
