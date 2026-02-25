# GCP IAM

Terraform module for managing GCP IAM resources including service accounts, custom roles, and workload identity bindings.

## Features

- Create and manage GCP service accounts with optional key generation
- Assign IAM roles to service accounts across projects
- Create custom IAM roles with specific permissions
- Configure workload identity bindings for Kubernetes service accounts
- Manage organization-level IAM role bindings

## Usage

```hcl
module "iam" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=gcp_iam/v0.1.0"

  project = "my-gcp-project"

  service_accounts = [
    {
      account_id   = "my-service-account"
      display_name = "My Service Account"
      description  = "Service account for application workloads"
      iam_bindings = [
        { role = "roles/storage.objectViewer" },
        { role = "roles/pubsub.subscriber" }
      ]
    }
  ]

  custom_roles = [
    {
      role_id     = "customReader"
      title       = "Custom Reader"
      description = "Custom role with read permissions"
      permissions = [
        "storage.buckets.get",
        "storage.objects.get"
      ]
    }
  ]

  workload_identity_bindings = [
    {
      service_account_id  = "my-service-account"
      namespace           = "default"
      k8s_service_account = "my-k8s-sa"
    }
  ]

  project_iam_members = [
    {
      project = "my-gcp-project"
      role    = "roles/logging.logWriter"
      member  = "serviceAccount:external-sa@other-project.iam.gserviceaccount.com"
    },
    {
      project = "my-gcp-project"
      role    = "roles/monitoring.metricWriter"
      member  = "group:devops@example.com"
    }
  ]

  organization_id = "123456789012"
  organization_iam_bindings = [
    {
      role = "roles/viewer"
      members = [
        "serviceAccount:my-service@my-project.iam.gserviceaccount.com",
        "user:admin@example.com"
      ]
    },
    {
      role = "organizations/123456789012/roles/customOrgRole"
      members = [
        "group:admins@example.com"
      ]
    }
  ]
}
```

## Requirements

| Name      | Version       |
| --------- | ------------- |
| terraform | >= 1.1, < 2.0 |
| google    | ~> 7          |

## Inputs

| Name                       | Description                                             | Type           | Required | Default |
| -------------------------- | ------------------------------------------------------- | -------------- | -------- | ------- |
| project                    | Default GCP project ID                                  | `string`       | Yes      | -       |
| service_accounts           | List of service accounts to manage                      | `list(object)` | No       | `[]`    |
| custom_roles               | List of custom IAM roles to manage                      | `list(object)` | No       | `[]`    |
| workload_identity_bindings | List of workload identity bindings                      | `list(object)` | No       | `[]`    |
| project_iam_members        | List of project-level IAM member bindings               | `list(object)` | No       | `[]`    |
| organization_id            | GCP organization ID for organization-level IAM bindings | `string`       | No       | `null`  |
| organization_iam_bindings  | List of organization-level IAM role bindings            | `list(object)` | No       | `[]`    |

### service_accounts object

| Attribute    | Description                             | Type           | Required | Default |
| ------------ | --------------------------------------- | -------------- | -------- | ------- |
| account_id   | The service account ID                  | `string`       | Yes      | -       |
| display_name | Display name for the service account    | `string`       | No       | `null`  |
| description  | Description of the service account      | `string`       | No       | `null`  |
| project      | Project ID (overrides default)          | `string`       | No       | `null`  |
| create_key   | Whether to create a service account key | `bool`         | No       | `false` |
| iam_bindings | List of IAM role bindings               | `list(object)` | No       | `[]`    |

#### iam_bindings nested object

| Attribute | Description                                                    | Type     | Required | Default |
| --------- | -------------------------------------------------------------- | -------- | -------- | ------- |
| role      | IAM role to assign (e.g., "roles/storage.objectViewer")        | `string` | Yes      | -       |
| project   | Project ID for the binding (overrides service account project) | `string` | No       | `null`  |

### custom_roles object

| Attribute   | Description                       | Type           | Required | Default |
| ----------- | --------------------------------- | -------------- | -------- | ------- |
| role_id     | The role ID                       | `string`       | Yes      | -       |
| title       | Human-readable title for the role | `string`       | Yes      | -       |
| description | Description of the role           | `string`       | No       | `null`  |
| permissions | List of permissions for the role  | `list(string)` | Yes      | -       |
| project     | Project ID (overrides default)    | `string`       | No       | `null`  |

### workload_identity_bindings object

| Attribute             | Description                                 | Type     | Required | Default |
| --------------------- | ------------------------------------------- | -------- | -------- | ------- |
| service_account_id    | Service account ID (created by this module) | `string` | No\*     | `null`  |
| service_account_email | Service account email (external)            | `string` | No\*     | `null`  |
| namespace             | Kubernetes namespace                        | `string` | Yes      | -       |
| k8s_service_account   | Kubernetes service account name             | `string` | Yes      | -       |
| project               | Project ID (overrides default)              | `string` | No       | `null`  |

\*Exactly one of `service_account_id` or `service_account_email` must be set.

### project_iam_members object

| Attribute | Description                    | Type     | Required | Default |
| --------- | ------------------------------ | -------- | -------- | ------- |
| project   | GCP project ID for the binding | `string` | Yes      | -       |
| role      | IAM role to assign             | `string` | Yes      | -       |
| member    | Member identity to bind        | `string` | Yes      | -       |

**Note**: Members should be prefixed with their type (e.g., `user:`, `serviceAccount:`, `group:`, `domain:`).

### organization_iam_bindings object

| Attribute | Description                         | Type           | Required | Default |
| --------- | ----------------------------------- | -------------- | -------- | ------- |
| role      | Full IAM role identifier            | `string`       | Yes      | -       |
| members   | List of members to bind to the role | `list(string)` | Yes      | -       |

**Note**:

- Role must include the full identifier:
  - Predefined roles: `roles/viewer`, `roles/editor`
  - Organization custom roles: `organizations/{ORG_ID}/roles/{ROLE_ID}`
  - Project custom roles: `projects/{PROJECT_ID}/roles/{ROLE_ID}`
- Members should be prefixed with their type (e.g., `user:`, `serviceAccount:`, `group:`, `domain:`)

## Outputs

| Name                      | Description                                                            |
| ------------------------- | ---------------------------------------------------------------------- |
| service_accounts          | Map of created service accounts with account_id, email, name, and id   |
| service_account_keys      | Map of created service account keys (sensitive)                        |
| custom_roles              | Map of created custom IAM roles with role_id, id, and name             |
| project_iam_bindings      | Map of created project-level IAM member bindings                       |
| organization_iam_bindings | Map of created organization IAM bindings with org_id, role, and member |
