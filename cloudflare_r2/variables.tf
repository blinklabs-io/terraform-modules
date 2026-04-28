variable "account_id" {
  type = string
}
variable "name" {
  type = string
}
variable "location" {
  description = "Location hint for the R2 bucket (e.g. `apac`, `eeur`, `enam`, `weur`, `wnam`)."
  type        = string
  default     = null
}
variable "storage_class" {
  description = "Storage class for the R2 bucket. One of `Standard` or `InfrequentAccess`."
  type        = string
  default     = "Standard"
}
