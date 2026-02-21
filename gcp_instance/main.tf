locals {
  region = join("-", slice(split("-", var.zone), 0, 2))
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

  source_ranges = ["0.0.0.0/0"]
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

  tags = var.tags
}
