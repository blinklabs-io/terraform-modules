resource "google_compute_network" "this" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
  project                 = var.project
}

resource "google_compute_subnetwork" "this" {
  name          = "${var.cluster_name}-subnet"
  ip_cidr_range = var.vpc_cidr
  region        = var.region
  network       = google_compute_network.this.name
  project       = var.project

  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = var.pod_cidr
  }

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = var.services_cidr
  }
}
