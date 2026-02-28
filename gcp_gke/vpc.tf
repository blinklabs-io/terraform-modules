resource "google_compute_network" "this" {
  name                     = local.vpc_name
  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = var.enable_ula_internal_ipv6
  project                  = var.project_id
}

resource "google_compute_subnetwork" "this" {
  name             = local.subnet_name
  ip_cidr_range    = var.vpc_cidr
  region           = var.region
  network          = google_compute_network.this.id
  project          = var.project_id
  stack_type       = var.stack_type
  ipv6_access_type = var.ipv6_access_type

  secondary_ip_range {
    range_name    = local.pod_range_name
    ip_cidr_range = var.pod_cidr
  }

  secondary_ip_range {
    range_name    = local.services_range_name
    ip_cidr_range = var.services_cidr
  }
}
