# cloudflare_page

Requirements:
- `cloudflare` provider

Required variables:
- `account_id`
- `owner`
- `page_name`
- `repo_name`
- `zone_name`

Optional variables:
```
variable "build_command" {
  type    = string
  default = "npm run build"
}
variable "deployment_variables" {
  type    = map(any)
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
variable "preview_deployment_variables" {
  type    = map(any)
  default = {}
}
variable "production_branch" {
  type    = string
  default = "main"
}
variable "root_dir" {
  type    = string
  default = ""
}
```
