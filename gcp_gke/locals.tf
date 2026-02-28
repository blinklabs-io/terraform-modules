locals {
  vpc_name            = (var.vpc_name != null && var.vpc_name != "") ? var.vpc_name : "${var.cluster_name}-vpc"
  subnet_name         = (var.subnet_name != null && var.subnet_name != "") ? var.subnet_name : "${var.cluster_name}-subnet"
  pod_range_name      = (var.pod_range_name != null && var.pod_range_name != "") ? var.pod_range_name : "${var.cluster_name}-pod-range"
  services_range_name = (var.services_range_name != null && var.services_range_name != "") ? var.services_range_name : "${var.cluster_name}-services-range"

  node_sa_email = var.node_service_account != null ? var.node_service_account : google_service_account.node["this"].email
}
