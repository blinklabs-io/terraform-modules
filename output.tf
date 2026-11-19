output "key_ring_id" {
  description = "Full resource ID of the key ring: projects/{project}/locations/{location}/keyRings/{name}"
  value       = google_kms_key_ring.this.id
}

output "key_ids" {
  description = "Map of key name to full crypto key resource ID"
  value       = { for name, key in google_kms_crypto_key.this : name => key.id }
}
