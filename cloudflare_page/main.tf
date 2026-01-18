resource "cloudflare_pages_project" "this" {
  account_id        = var.account_id
  name              = var.page_name
  production_branch = var.production_branch

  source = {
    type = "github"
    config = {
      owner                         = var.owner
      repo_name                     = var.repo_name
      production_branch             = var.production_branch
      pr_comments_enabled           = true
      deployments_enabled           = true
      production_deployment_enabled = true
      preview_deployment_setting    = "all"
      preview_branch_includes       = ["*"]
    }
  }

  build_config = {
    build_command   = var.build_command
    destination_dir = var.destination_dir
    root_dir        = var.root_dir
  }

  deployment_configs = {
    preview = {
      fail_open             = true
      environment_variables = var.preview_deployment_variables != {} ? var.preview_deployment_variables : var.deployment_variables
    }
    production = {
      fail_open             = true
      environment_variables = var.deployment_variables
    }
  }
}

resource "cloudflare_pages_domain" "this" {
  for_each = toset([for r in var.domains : r])

  depends_on   = [cloudflare_pages_project.this]
  account_id   = var.account_id
  project_name = var.page_name
  name         = each.value
}

data "cloudflare_zone" "this" {
  filter = {
    name = var.zone_name
  }
}

resource "cloudflare_dns_record" "this" {
  for_each = toset([for r in var.domains : r if r != data.cloudflare_zone.this.name])

  zone_id = data.cloudflare_zone.this.id
  name    = each.value
  content = cloudflare_pages_project.this.subdomain
  type    = "CNAME"
  ttl     = 1
  proxied = true
}
