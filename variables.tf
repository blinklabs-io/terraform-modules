variable "name" {
  type = string
}
variable "account_id" {
  type = string
}
variable "default_pool_ids" {
  default = null
}
variable "fallback_pool_id" {
  default = null
}
variable "load_balancer_monitor_id" {
  default = null
}
variable "monitor_enabled" {
  type    = bool
  default = true
}
variable "monitor_expected_codes" {
  type    = string
  default = "200"
}
variable "monitor_headers" {
  type    = map(list(string))
  default = {}
}
variable "monitor_interval" {
  type    = number
  default = 60
}
variable "monitor_method" {
  type    = string
  default = "GET"
}
variable "monitor_path" {
  type    = string
  default = "/"
}
variable "monitor_retries" {
  type    = number
  default = 3
}
variable "monitor_timeout" {
  type    = number
  default = 5
}
variable "monitor_type" {
  type    = string
  default = "http"
}
variable "origins" {
  type = list(object({
    name    = string
    address = string
  }))
  default = []
}
variable "zone_name" {
  type = string
}
