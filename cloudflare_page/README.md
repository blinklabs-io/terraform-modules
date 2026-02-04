# Cloudflare Pages

This module creates a Cloudflare Pages project with GitHub integration, custom domains, and DNS records. It configures automatic deployments for both preview and production branches.

## Usage

```hcl
module "cloudflare_page" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git//cloudflare_page?ref=cloudflare_page/v0.1.0"

  account_id  = "your-cloudflare-account-id"
  page_name   = "my-website"
  owner       = "my-github-org"
  repo_name   = "my-repo"
  zone_name   = "example.com"
  domains     = ["www.example.com", "example.com"]

  build_command   = "npm run build"
  destination_dir = "out"

  deployment_variables = {
    NODE_ENV = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1, < 2.0 |
| cloudflare | ~> 5 |

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| account_id | Cloudflare account ID | `string` | Yes | - |
| build_command | Build command to run | `string` | No | `"npm run build"` |
| deployment_variables | Environment variables for production (and preview if preview_deployment_variables is not set) | `map(any)` | No | `{}` |
| destination_dir | Output directory for built assets | `string` | No | `"out"` |
| domains | List of custom domains to attach to the Pages project | `list(string)` | No | `[]` |
| owner | GitHub repository owner | `string` | Yes | - |
| page_name | Name of the Cloudflare Pages project | `string` | Yes | - |
| preview_deployment_variables | Environment variables for preview deployments | `map(any)` | No | `{}` |
| production_branch | Git branch for production deployments | `string` | No | `"main"` |
| repo_name | GitHub repository name | `string` | Yes | - |
| root_dir | Root directory for the build | `string` | No | `""` |
| zone_name | Cloudflare DNS zone name for custom domain records | `string` | Yes | - |

## Outputs

This module does not export any outputs.
