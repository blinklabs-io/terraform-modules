# GCP KMS

Terraform module for managing a GCP Cloud KMS key ring, its crypto keys, and per-key IAM access.

## Features

- Create a key ring in a project and location
- Create crypto keys of any purpose, with optional automatic rotation, version template (algorithm and protection level), destroy scheduled duration, and labels
- Grant roles on individual keys to any principal, including workload identity pool `principalSet://` and `principal://` values, using additive `google_kms_crypto_key_iam_member` bindings

## Usage

```hcl
module "kms" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=gcp_kms/v0.1.0"

  project  = "my-gcp-project"
  location = "us-central1"
  name     = "app"

  keys = {
    data = {
      rotation_period            = "7776000s"
      destroy_scheduled_duration = "2592000s"
      labels                     = { env = "prod" }
      iam_members = {
        "roles/cloudkms.cryptoKeyEncrypterDecrypter" = [
          "serviceAccount:app@my-gcp-project.iam.gserviceaccount.com",
          "principalSet://iam.googleapis.com/projects/123456789/locations/global/workloadIdentityPools/external/attribute.team/platform",
        ]
      }
    }

    signing = {
      purpose = "ASYMMETRIC_SIGN"
      version_template = {
        algorithm        = "EC_SIGN_P256_SHA256"
        protection_level = "HSM"
      }
      iam_members = {
        "roles/cloudkms.signer" = ["group:release@example.com"]
      }
    }
  }
}
```

## Protection from destruction

GCP does not delete key rings or crypto keys. Removing either from Terraform
destroys the key versions only; the names stay reserved in the project and
location. Terraform's `lifecycle.prevent_destroy` cannot be driven by a
variable, so this module does not set it. Set `destroy_scheduled_duration` on
each key so a destroyed version remains recoverable for that period, and review
plans for `google_kms_crypto_key` destroy actions. `destroy_scheduled_duration`
cannot be changed after a key is created.

IAM bindings are additive: the module never removes members it did not grant.
Members used in `iam_members` must be known at plan time because they form part
of the resource address.

## Requirements

| Name      | Version       |
| --------- | ------------- |
| terraform | >= 1.1, < 2.0 |
| google    | ~> 7          |

## Inputs

| Name     | Description                                              | Type          | Required | Default |
| -------- | -------------------------------------------------------- | ------------- | -------- | ------- |
| project  | GCP project ID that owns the key ring                    | `string`      | Yes      | -       |
| location | Location of the key ring (region, multi-region, `global`) | `string`      | Yes      | -       |
| name     | Name of the key ring                                     | `string`      | Yes      | -       |
| keys     | Crypto keys to create, keyed by key name                 | `map(object)` | No       | `{}`    |

### keys object

| Attribute                  | Description                                                                                          | Type                 | Required | Default             |
| -------------------------- | ---------------------------------------------------------------------------------------------------- | -------------------- | -------- | ------------------- |
| purpose                    | `ENCRYPT_DECRYPT`, `ASYMMETRIC_SIGN`, `ASYMMETRIC_DECRYPT`, `RAW_ENCRYPT_DECRYPT`, or `MAC`          | `string`             | No       | `"ENCRYPT_DECRYPT"` |
| rotation_period            | Automatic rotation period in seconds, such as `7776000s`; `ENCRYPT_DECRYPT` keys only                | `string`             | No       | `null`              |
| version_template           | Algorithm and protection level of new versions; required unless purpose is `ENCRYPT_DECRYPT`         | `object`             | No       | `null`              |
| destroy_scheduled_duration | Recovery period for destroyed versions in seconds, such as `2592000s`; immutable after creation      | `string`             | No       | `null`              |
| labels                     | Labels for the key                                                                                   | `map(string)`        | No       | `{}`                |
| iam_members                | Map of role to list of members granted that role on the key                                          | `map(list(string))`  | No       | `{}`                |

#### version_template nested object

| Attribute        | Description                                           | Type     | Required | Default      |
| ---------------- | ----------------------------------------------------- | -------- | -------- | ------------ |
| algorithm        | Algorithm of new key versions                         | `string` | Yes      | -            |
| protection_level | `SOFTWARE`, `HSM`, `EXTERNAL`, or `EXTERNAL_VPC`      | `string` | No       | `"SOFTWARE"` |

## Outputs

| Name        | Description                                  |
| ----------- | -------------------------------------------- |
| key_ring_id | Full resource ID of the key ring             |
| key_ids     | Map of key name to full crypto key resource ID |
