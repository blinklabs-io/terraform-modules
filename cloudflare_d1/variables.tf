variable "account_id" {
  type = string
}
variable "name" {
  type = string
}
variable "primary_location_hint" {
  type    = string
  default = null
}
variable "read_replication" {
  description = "Read replication configuration. Set mode to \"auto\" or \"disabled\"."
  type = object({
    mode = string
  })
  default = null
}