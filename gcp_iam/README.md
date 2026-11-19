# GCP IAM

Terraform module for managing GCP IAM resources including service accounts, custom roles, and workload identity bindings.

## Features

- Create and manage GCP service accounts with optional key generation
- Assign IAM roles to service accounts across projects
- Create custom IAM roles with specific permissions
- Configure workload identity bindings for Kubernetes service accounts
- Create workload identity pools with OIDC or AWS providers, and let their principals impersonate service accounts without service account keys
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

### Workload identity federation

```hcl
module "iam" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=gcp_iam/v0.4.0"

  project = "my-gcp-project"

  service_accounts = [
    {
      account_id   = "external-deployer"
      iam_bindings = [{ role = "roles/container.clusterViewer" }]
    }
  ]

  workload_identity_pools = [
    {
      pool_id = "external"
      providers = [
        {
          provider_id = "example-oidc"
          issuer_uri  = "https://oidc.example.com"
          attribute_mapping = {
            "google.subject" = "assertion.sub"
            "attribute.team" = "assertion.team"
          }
          attribute_condition = "assertion.team == 'platform'"
        }
      ]
    }
  ]

  workload_identity_pool_bindings = [
    {
      service_account_id = "external-deployer"
      pool_id            = "external"
      attribute          = "subject"
      value              = "deploy:production"
    }
  ]
}
```

The `name` in the `workload_identity_pool_providers` output is the full
provider resource name that identifies the provider in a token exchange.

An AWS provider uses the AWS account ID instead of an OIDC issuer. Its
attribute condition should narrow access to the intended roles in that account:

```hcl
workload_identity_pools = [
  {
    pool_id = "aws-workloads"
    providers = [
      {
        provider_id    = "production"
        aws_account_id = "123456789012"
        attribute_mapping = {
          "google.subject"    = "assertion.arn"
          "attribute.aws_role" = "assertion.arn.extract('assumed-role/{role}/')"
        }
        attribute_condition = "assertion.account == '123456789012' && attribute.aws_role == 'production-deployer'"
      }
    ]
  }
]
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
| workload_identity_pools    | Workload identity pools with OIDC or AWS providers       | `list(object)` | No       | `[]`    |
| workload_identity_pool_bindings | Service account impersonation grants for pool principals | `list(object)` | No | `[]` |

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

### workload_identity_pools object

| Attribute    | Description                     | Type           | Required | Default |
| ------------ | ------------------------------- | -------------- | -------- | ------- |
| pool_id      | Workload identity pool ID       | `string`       | Yes      | -       |
| display_name | Display name for the pool       | `string`       | No       | `null`  |
| description  | Description of the pool         | `string`       | No       | `null`  |
| project      | Project ID (overrides default)  | `string`       | No       | `null`  |
| disabled     | Whether the pool is disabled    | `bool`         | No       | `false` |
| providers    | OIDC or AWS providers in the pool | `list(object)` | No     | `[]`    |

#### providers nested object

| Attribute           | Description                                                  | Type           | Required | Default |
| ------------------- | ------------------------------------------------------------ | -------------- | -------- | ------- |
| provider_id         | Provider ID                                                  | `string`       | Yes      | -       |
| display_name        | Display name for the provider                                | `string`       | No       | `null`  |
| description         | Description of the provider                                  | `string`       | No       | `null`  |
| issuer_uri          | OIDC issuer URI                                              | `string`       | No\*     | `null`  |
| aws_account_id      | AWS account ID                                               | `string`       | No\*     | `null`  |
| allowed_audiences   | Accepted token audiences; empty accepts the provider's default | `list(string)` | No     | `[]`    |
| attribute_mapping   | Map of Google attributes to token assertions                 | `map(string)`  | Yes      | -       |
| attribute_condition | CEL condition a token must satisfy; must not be empty        | `string`       | Yes      | -       |

\*Exactly one of `issuer_uri` or `aws_account_id` must be set.

**Note**: A provider without an attribute condition accepts every token from its
issuer. For a shared public issuer, such as a hosted CI service, that is every
one of its users, so the module rejects an empty condition.

### workload_identity_pool_bindings object

| Attribute             | Description                                          | Type     | Required | Default |
| --------------------- | ---------------------------------------------------- | -------- | -------- | ------- |
| service_account_id    | Service account ID (created by this module)          | `string` | No\*     | `null`  |
| service_account_email | Service account email (external)                     | `string` | No\*     | `null`  |
| project               | Project ID (overrides default)                       | `string` | No       | `null`  |
| pool_id               | Pool ID (created by this module)                     | `string` | Yes      | -       |
| attribute             | `subject`, `group`, or `attribute.<name>`\*\*        | `string` | Yes      | -       |
| value                 | Value that selects the principal or principal set    | `string` | Yes      | -       |

\*Exactly one of `service_account_id` or `service_account_email` must be set.

\*\*`<name>` is 1-100 lowercase letters, digits, or underscores, and must be
mapped by the provider's `attribute_mapping`.

`subject` grants a single principal; any other attribute grants every principal
whose mapped attribute has that value.

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
| workload_identity_pool_providers | Map of created workload identity pool providers with their full resource name |
