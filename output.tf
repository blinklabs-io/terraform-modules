output "instance_name" {
  description = "Name of the created compute instance."
  value       = google_compute_instance.this.name
}

output "external_ip" {
  description = "Static external IP address assigned to the instance. Null when assign_external_ip is false."
  value       = one(google_compute_address.this[*].address)
}
