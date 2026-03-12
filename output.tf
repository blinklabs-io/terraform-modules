output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = module.gke.ca_certificate
  sensitive   = true
}

output "node_service_account" {
  description = "Node pool service account email"
  value       = local.node_sa_email
}

output "vpc" {
  description = "VPC network details"
  value = {
    name                 = google_compute_network.this.name
    id                   = google_compute_network.this.id
    subnetwork           = google_compute_subnetwork.this.name
    subnetwork_id        = google_compute_subnetwork.this.id
    subnetwork_self_link = google_compute_subnetwork.this.self_link
  }
}
