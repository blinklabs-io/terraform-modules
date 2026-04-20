variable "cluster_name" {
  type = string
}
variable "cluster_version" {
  default = "1.32"
  type    = string
}
variable "cidr" {
  default = "10.10.0.0/16"
  type    = string
}
variable "azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1d"]
  type    = list(string)
}
variable "private_subnets" {
  default = ["10.10.48.0/20"]
  type    = list(string)
}
variable "public_subnets" {
  default = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]
  type    = list(string)
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "node_groups" {
  default = {}
}
variable "enable_external_dns" {
  description = "Whether to create an IRSA role for external-dns"
  type        = bool
  default     = false
}

variable "external_dns_hosted_zone_arns" {
  description = "Route53 hosted zone ARNs to allow External DNS to manage records"
  type        = list(string)
  default     = []
}
