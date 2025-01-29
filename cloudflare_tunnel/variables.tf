variable "account_id" {
  type = string
}
variable "name" {
  type = string
}
variable "zone_id" {
  type = string
}
variable "secret" {
  type      = string
  sensitive = true
}
variable "ingress_rules" {
  type = list(object({
    hostname = string
    service  = string
    dns      = optional(bool, true)
    origin_request = optional(object({
      http2_origin  = optional(bool, false)
      no_tls_verify = optional(bool, false)
    }))
  }))
  default = []
}
