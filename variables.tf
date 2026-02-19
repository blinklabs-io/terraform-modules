variable "account_id" {
  type = string
}
variable "build_command" {
  type    = string
  default = "npm run build"
}
variable "deployment_variables" {
  type = map(object({
    type  = string
    value = string
  }))
  default = {}
}
variable "destination_dir" {
  type    = string
  default = "out"
}
variable "domains" {
  type    = list(string)
  default = []
}
variable "owner" {
  type = string
}
variable "page_name" {
  type = string
}
variable "preview_deployment_variables" {
  type = map(object({
    type  = string
    value = string
  }))
  default = {}
}
variable "production_branch" {
  type    = string
  default = "main"
}
variable "repo_name" {
  type = string
}
variable "root_dir" {
  type    = string
  default = ""
}
variable "zone_name" {
  type = string
}
