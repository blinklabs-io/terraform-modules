variable "account_id" {
  type        = string
  description = "Cloudflare account ID (use for account-level rulesets)"
  default     = null
}
variable "zone_id" {
  type        = string
  description = "Cloudflare zone ID (use for zone-level rulesets)"
  default     = null
}
variable "kind" {
  type = string
}
variable "name" {
  type = string
}
variable "phase" {
  type = string
}
variable "status_code" {
  type = number
}
variable "target_url" {
  type = string
}
variable "zone_name" {
  type        = string
  description = "Zone name to lookup (only needed when zone_id is not provided)"
  default     = null
}
