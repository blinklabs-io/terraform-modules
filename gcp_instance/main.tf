locals {
  region       = join("-", slice(split("-", var.zone), 0, 2))
  confidential = var.confidential_instance_type != null
  spot         = var.spot == true

  # scheduling is Optional+Computed in the provider: omitting the block keeps
  # whatever the instance already has, so spot = false must render it to move
  # a Spot VM back to STANDARD. With spot = null and no confidential type the
  # block stays omitted and existing instances show no diff.
  custom_scheduling = local.confidential || var.spot != null

  # An existing subnetwork replaces both the module's VPC and the default lookup.
  create_network = var.use_default_network == false && var.subnetwork == null
  lookup_default = var.use_default_network && var.subnetwork == null
}

resource "google_compute_network" "this" {
  for_each                = toset([for n in [var.name] : n if local.create_network])
  name                    = each.key
  project                 = var.project
  auto_create_subnetworks = false
}

data "google_compute_subnetwork" "this" {
  for_each = toset([for n in ["default"] : n if local.lookup_default])
  name     = each.key
  region   = local.region
  project  = var.project
}

resource "google_compute_subnetwork" "this" {
  for_each      = toset([for n in [var.name] : n if local.create_network])
  name          = each.key
  ip_cidr_range = var.ip_cidr_range
  region        = local.region
  network       = google_compute_network.this[var.name].id
  project       = var.project
}

resource "google_compute_firewall" "this" {
  for_each = toset([for n in [var.name] : n if local.create_network && length(var.allow_ports) > 0])
  name     = "${each.key}-allow"
  network  = google_compute_network.this[var.name].id
  project  = var.project

  allow {
    protocol = "tcp"
    ports    = [for p in var.allow_ports : tostring(p)]
  }

  source_ranges = var.allow_source_ranges
}

resource "google_compute_address" "this" {
  count   = var.assign_external_ip ? 1 : 0
  name    = var.name
  region  = local.region
  project = var.project
}

moved {
  from = google_compute_address.this
  to   = google_compute_address.this[0]
}

resource "google_compute_instance" "this" {
  name         = var.name
  machine_type = var.machine_type
  project      = var.project
  zone         = var.zone

  # The provider requires AMD Milan for SEV_SNP; null keeps the computed value.
  min_cpu_platform = var.confidential_instance_type == "SEV_SNP" ? "AMD Milan" : null

  metadata = merge(
    { block-project-ssh-keys = "true" },
    var.metadata,
  )

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
    }
  }

  network_interface {
    # A self_link or projects/ path carries its own project, which the provider
    # reads back into subnetwork_project; forcing var.project there diffs forever.
    subnetwork         = var.subnetwork != null ? var.subnetwork : (var.use_default_network ? data.google_compute_subnetwork.this["default"].self_link : google_compute_subnetwork.this[var.name].self_link)
    subnetwork_project = var.subnetwork != null && can(regex("^(https://|projects/)", var.subnetwork)) ? null : var.project

    dynamic "access_config" {
      for_each = var.assign_external_ip ? [1] : []
      content {
        nat_ip = google_compute_address.this[0].address
      }
    }
  }

  dynamic "service_account" {
    for_each = var.service_account_email != null ? [1] : []
    content {
      email  = var.service_account_email
      scopes = var.service_account_scopes
    }
  }

  dynamic "confidential_instance_config" {
    for_each = local.confidential ? [1] : []
    content {
      confidential_instance_type = var.confidential_instance_type
    }
  }

  dynamic "shielded_instance_config" {
    for_each = var.shielded_instance_config != null ? [var.shielded_instance_config] : []
    content {
      enable_secure_boot          = shielded_instance_config.value.enable_secure_boot
      enable_vtpm                 = shielded_instance_config.value.enable_vtpm
      enable_integrity_monitoring = shielded_instance_config.value.enable_integrity_monitoring
    }
  }

  dynamic "scheduling" {
    for_each = local.custom_scheduling ? [1] : []
    content {
      provisioning_model = local.spot ? "SPOT" : "STANDARD"
      preemptible        = local.spot
      automatic_restart  = !local.spot
      # Confidential and Spot VMs cannot live-migrate, so GCP requires TERMINATE.
      on_host_maintenance         = local.confidential || local.spot ? "TERMINATE" : "MIGRATE"
      instance_termination_action = local.spot ? var.instance_termination_action : null
    }
  }

  tags = var.tags

  # Cross-variable validation blocks need Terraform 1.9; this runs on 1.3.
  lifecycle {
    precondition {
      condition     = !(var.subnetwork != null && var.use_default_network)
      error_message = "subnetwork cannot be combined with use_default_network = true."
    }
  }
}
