variable "account_id" {
  type = string
}
variable "a_records" {
  type = list(object({
    name        = string
    record_name = string
    content     = string
    proxied     = optional(bool, true)
  }))
  default = []
}
variable "cname_records" {
  type = list(object({
    name        = string
    record_name = string
    content     = string
    proxied     = optional(bool, true)
  }))
  default = []
}
variable "mx_records" {
  type = list(object({
    value    = string
    priority = number
  }))
  default = []
}
variable "txt_records" {
  type = list(object({
    name        = string
    record_name = string
    content     = string
  }))
  default = []
}
variable "plan" {
  type    = string
  default = "free"
}
variable "zone_name" {
  type = string
}
