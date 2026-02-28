# gcp_project

GCP project module for creating and managing Google Cloud projects with optional service enablement and a terraform-runner service account at the organization level.

## Requirements

- Terraform >= 1.3
- `hashicorp/google` provider >= 7.0

## Module Features

- Create one or more GCP projects under an organization or folder
- Enable Google services globally or per project
- Optional terraform-runner service account with organization-level IAM bindings
- Per-project billing account and folder overrides
- Configurable project deletion policy

## Bootstrap Flow

This module is designed to be run once by an admin user with organization-level credentials:

```bash
gcloud auth application-default login
terraform apply
```

On the first run, all projects are created and the terraform-runner service account is provisioned. Subsequent runs can use the SA credentials via CI/CD.

## Variables

### Optional (at least one of `gcp_organization_id`, `gcp_folder_id`, or per-project `folder_id` required)

| Name                          | Type   | Default                          | Description                                                                                      |
| ----------------------------- | ------ | -------------------------------- | ------------------------------------------------------------------------------------------------ |
| `gcp_organization_id`         | string | `null`                           | GCP organization ID (numeric). Required when `enable_terraform_runner=true`                      |
| `gcp_folder_id`               | string | `null`                           | GCP folder ID (numeric). Projects created here unless overridden per project                     |
| `gcp_billing_account`         | string | `null`                           | Default billing account ID applied to all projects unless overridden                             |
| `env_vars`                    | object | `{ google = { projects = [] } }` | Project configuration list (see structure below)                                                 |
| `services`                    | list   | `[]`                             | Google services to enable across all created projects                                            |
| `enable_terraform_runner`     | bool   | `false`                          | Create and configure the terraform-runner service account                                        |
| `export_terraform_runner_key` | bool   | `false`                          | Emit the SA key as a sensitive output. Off by default to avoid storing raw key material in state |
| `terraform_runner_account_id` | string | `"terraform-runner"`             | Service account ID for the terraform runner                                                      |
| `terraform_runner_roles`      | list   | See below                        | IAM roles to assign to the terraform-runner service account                                      |
| `deletion_policy`             | string | `"PREVENT"`                      | Project deletion policy: `PREVENT`, `ABANDON`, or `DELETE`                                       |
| `project_create_timeout`      | string | `"10m"`                          | Timeout for creating projects                                                                    |
| `project_update_timeout`      | string | `"10m"`                          | Timeout for updating projects                                                                    |
| `project_delete_timeout`      | string | `"10m"`                          | Timeout for deleting projects                                                                    |
| `service_create_timeout`      | string | `"30m"`                          | Timeout for enabling services                                                                    |
| `service_update_timeout`      | string | `"30m"`                          | Timeout for updating services                                                                    |
| `service_disable_on_destroy`  | bool   | `false`                          | Whether to disable a Google service when its resource is destroyed                               |

### `env_vars` Project Structure

```hcl
env_vars = {
  google = {
    projects = [
      {
        project_id      = string           # required — GCP project ID (6-30 chars, lowercase, hyphens)
        display_name    = optional(string) # optional — GCP display name (4-30 chars), defaults to project_id
        admin           = optional(bool)   # optional — designates this as the terraform-runner home project
        network         = optional(bool)   # optional — auto-create default VPC network (default: false); GCP implicitly enables compute.googleapis.com regardless
        firebase        = optional(bool)   # optional — label project for Firebase discovery (default: false)
        services        = optional(list)   # optional — services to enable for this project only
        folder_id       = optional(string) # optional — override module-level folder for this project
        billing_account = optional(string) # optional — override module-level billing account
      }
    ]
  }
}
```

**Rules:**

- `project_id` values must be unique across the list
- At most one project can have `admin = true`
- When `enable_terraform_runner = true`, exactly one project must have `admin = true`
- When `enable_terraform_runner = true`, `gcp_organization_id` must be set

#### Default `terraform_runner_roles`

```text
- resourcemanager.projectCreator
```

## Outputs

| Name                           | Description                                                                                           |
| ------------------------------ | ----------------------------------------------------------------------------------------------------- |
| `projects`                     | Map of created projects with project ID, number, and display name                                     |
| `services`                     | Map of project ID to list of enabled Google services                                                  |
| `terraform_runner_email`       | Email of terraform-runner service account (null if disabled)                                          |
| `terraform_runner_private_key` | Base64-encoded SA key (sensitive). Null unless `export_terraform_runner_key = true` and SA is enabled |

## Example Usage

### Full Setup with Terraform Runner

```hcl
module "gcp_project" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=gcp_project/v0.1.0"

  gcp_organization_id = "123456789"
  gcp_billing_account = "0123AB-CDEF45-67890"

  enable_terraform_runner = true

  env_vars = {
    google = {
      projects = [
        {
          project_id = "my-org-admin"
          admin      = true
          services   = ["cloudbilling.googleapis.com"]
        },
        {
          project_id = "my-app-prod"
          services   = ["compute.googleapis.com", "container.googleapis.com"]
        },
        {
          project_id   = "my-app-firebase"
          display_name = "My Firebase App"
          firebase     = true
        }
      ]
    }
  }

  services = [
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
  ]
}
```

### Projects Under a Folder

```hcl
module "gcp_project" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=gcp_project/v0.1.0"

  gcp_organization_id = "123456789"
  gcp_folder_id       = "987654321"
  gcp_billing_account = "0123AB-CDEF45-67890"

  env_vars = {
    google = {
      projects = [
        { project_id = "my-app-prod" },
        { project_id = "my-app-staging" }
      ]
    }
  }
}
```

### Per-Project Billing and Folder Overrides

```hcl
module "gcp_project" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=gcp_project/v0.1.0"

  gcp_organization_id = "123456789"
  gcp_billing_account = "0123AB-CDEF45-67890"

  env_vars = {
    google = {
      projects = [
        {
          project_id      = "my-app-prod"
          billing_account = "AABBCC-DDEEFF-112233"
          folder_id       = "111222333"
        },
        {
          project_id = "my-app-staging"
        }
      ]
    }
  }
}
```

### Extending Timeouts for Slow Environments

```hcl
module "gcp_project" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=gcp_project/v0.1.0"

  gcp_organization_id = "123456789"
  gcp_billing_account = "0123AB-CDEF45-67890"

  env_vars = {
    google = {
      projects = [
        { project_id = "my-org-admin", admin = true },
        { project_id = "my-app-prod" }
      ]
    }
  }

  project_create_timeout = "15m"
  service_create_timeout = "45m"
  service_update_timeout = "45m"
}
```

## Notes

- Service account keys should be rotated regularly per GCP security best practices
- The terraform-runner service account is granted powerful organization-level permissions; restrict access accordingly
- `deletion_policy = "PREVENT"` (default) protects projects against any destroy actions from Terraform
- When `auto_create_network = false` (default), GCP still enables `compute.googleapis.com` on the project
- The `terraform_runner_private_key` output is marked sensitive but stored in Terraform state — ensure your state backend is encrypted and access-controlled. Set `export_terraform_runner_key = false` (default) to suppress it entirely
