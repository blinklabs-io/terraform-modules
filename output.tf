output "vpc" {
  description = "VPC network details"
  value = {
    name       = google_compute_network.this.name
    id         = google_compute_network.this.id
    subnetwork = google_compute_subnetwork.this.name
  }
}

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
  value       = google_service_account.node.email
}
