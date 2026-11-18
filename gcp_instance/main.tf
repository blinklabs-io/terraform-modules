locals {
  region       = join("-", slice(split("-", var.zone), 0, 2))
  confidential = var.confidential_instance_type != null

  # Confidential and Spot VMs cannot live-migrate, so GCP requires TERMINATE.
  # The scheduling block is only rendered when one of them is requested, so
  # existing instances keep the provider-computed scheduling and show no diff.
  custom_scheduling = local.confidential || var.spot
}

resource "google_compute_network" "this" {
  for_each                = toset([for n in [var.name] : n if var.use_default_network == false])
  name                    = each.key
  project                 = var.project
  auto_create_subnetworks = false
}

data "google_compute_subnetwork" "this" {
  for_each = toset([for n in ["default"] : n if var.use_default_network])
  name     = each.key
  region   = local.region
  project  = var.project
}

resource "google_compute_subnetwork" "this" {
  for_each      = toset([for n in [var.name] : n if var.use_default_network == false])
  name          = each.key
  ip_cidr_range = var.ip_cidr_range
  region        = local.region
  network       = google_compute_network.this[var.name].id
  project       = var.project
}

resource "google_compute_firewall" "this" {
  for_each = toset([for n in [var.name] : n if var.use_default_network == false && length(var.allow_ports) > 0])
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
  name    = var.name
  region  = local.region
  project = var.project
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
    subnetwork         = var.use_default_network ? data.google_compute_subnetwork.this["default"].self_link : google_compute_subnetwork.this[var.name].self_link
    subnetwork_project = var.project

    access_config {
      nat_ip = google_compute_address.this.address
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
      provisioning_model          = var.spot ? "SPOT" : "STANDARD"
      preemptible                 = var.spot
      automatic_restart           = !var.spot
      on_host_maintenance         = "TERMINATE"
      instance_termination_action = var.spot ? var.instance_termination_action : null
    }
  }

  tags = var.tags
}
