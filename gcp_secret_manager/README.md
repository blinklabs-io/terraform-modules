# GCP Secret Manager

Terraform module for managing Secret Manager secrets and their access in a single GCP project.

## Features

- Create secrets with automatic replication or user-managed replication in chosen locations
- Optional customer-managed encryption key per secret, or per replica location
- Labels, annotations, and an optional version destroy TTL per secret
- Additive per-secret IAM members, including workload identity pool principals
- Deletion protection on by default, since destroying a secret also destroys its versions

The module creates secrets without versions. Secret values are never managed by
Terraform and so never enter its state; add them out of band, for example with
`gcloud secrets versions add <id> --data-file=-`.

## Usage

```hcl
module "secrets" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=gcp_secret_manager/v0.1.0"

  project = "my-gcp-project"

  secrets = {
    api-token = {
      labels = { app = "api" }
      iam_members = {
        "roles/secretmanager.secretAccessor" = [
          "serviceAccount:api@my-gcp-project.iam.gserviceaccount.com",
          "principalSet://iam.googleapis.com/projects/123456789/locations/global/workloadIdentityPools/external/attribute.team/platform",
        ]
      }
    }

    regional-key = {
      replication_locations = {
        "us-east1" = { kms_key_name = "projects/my-gcp-project/locations/us-east1/keyRings/kr/cryptoKeys/key" }
        "us-west1" = { kms_key_name = "projects/my-gcp-project/locations/us-west1/keyRings/kr/cryptoKeys/key" }
      }
      version_destroy_ttl = "86400s"
    }
  }
}
```

## Requirements

| Name      | Version       |
| --------- | ------------- |
| terraform | >= 1.3, < 2.0 |
| google    | ~> 7          |

## Inputs

| Name    | Description                                  | Type          | Required | Default |
| ------- | -------------------------------------------- | ------------- | -------- | ------- |
| project | GCP project ID that holds the secrets        | `string`      | Yes      | -       |
| secrets | Secrets to create, keyed by secret ID        | `map(object)` | No       | `{}`    |

### secrets object

| Attribute             | Description                                                                              | Type                | Required | Default |
| --------------------- | ---------------------------------------------------------------------------------------- | ------------------- | -------- | ------- |
| labels                | Labels on the secret                                                                     | `map(string)`       | No       | `{}`    |
| annotations           | Annotations on the secret                                                                | `map(string)`       | No       | `{}`    |
| version_destroy_ttl   | Delay before a destroyed version is purged, in seconds (e.g. `"86400s"`)                 | `string`            | No       | `null`  |
| kms_key_name          | Customer-managed key for automatic replication                                           | `string`            | No       | `null`  |
| replication_locations | User-managed replication: location to optional per-replica `kms_key_name`; empty is automatic | `map(object)` | No | `{}` |
| iam_members           | Role to list of members, granted on the secret only                                      | `map(list(string))` | No       | `{}`    |
| deletion_protection   | Refuse to destroy or replace the secret                                                  | `bool`              | No       | `true`  |

**Note**:

- `kms_key_name` cannot be combined with `replication_locations`; set it on each location instead.
- Replication cannot change after creation: changing `replication_locations` or `kms_key_name` replaces the secret and destroys every version. While `deletion_protection` is `true` in state, an apply that would destroy the secret fails; apply it as `false` first to allow the replacement or removal.
- IAM grants are additive (`google_secret_manager_secret_iam_member`); members granted outside Terraform are left alone.
- Members use the usual prefixes (`user:`, `serviceAccount:`, `group:`, `principal://`, `principalSet://`).
- Each member is part of its resource key, so members must be known at plan time. A member built from a resource created in the same apply fails with "Invalid for_each argument".

## Outputs

| Name         | Description                                                 |
| ------------ | ----------------------------------------------------------- |
| secret_ids   | Map of secret key to secret ID                              |
| secret_names | Map of secret key to full resource name (`projects/<project>/secrets/<id>`) |
