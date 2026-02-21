# AWS IAM

This module manages AWS IAM users, policies, access keys, and user-policy attachments.

## Usage

```hcl
module "iam" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=aws_iam/v0.1.0"

  users = [
    {
      name          = "example-user"
      path          = "/users/"
      force_destroy = true
      policy_arns   = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      access_keys = [
        {
          id     = "key1"
          status = "Active"
        }
      ]
    }
  ]

  policies = [
    {
      name        = "example-policy"
      path        = "/policies/"
      description = "Example policy"
      statements = [
        {
          sid       = "AllowS3Read"
          effect    = "Allow"
          actions   = ["s3:GetObject", "s3:ListBucket"]
          resources = ["arn:aws:s3:::example-bucket/*"]
        }
      ]
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1, < 2.0 |
| aws | No version constraint |

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| users | List of users to manage | `list(object)` | Yes | n/a |
| policies | List of policies to manage | `list(object)` | Yes | n/a |

### users object

| Attribute | Description | Type | Required | Default |
|-----------|-------------|------|----------|---------|
| name | IAM user name | `string` | Yes | n/a |
| path | Path for the IAM user | `string` | No | `null` |
| permissions_boundary | ARN of the permissions boundary policy | `string` | No | `null` |
| force_destroy | Destroy user even if it has non-Terraform-managed access keys | `bool` | No | `null` |
| tags | Tags to assign to the user | `map(any)` | No | `null` |
| policy_arns | List of policy ARNs to attach to the user | `list(string)` | No | `[]` |
| access_keys | List of access keys to create for the user | `list(object)` | No | `[]` |

### access_keys object

| Attribute | Description | Type | Required | Default |
|-----------|-------------|------|----------|---------|
| id | Unique identifier for the access key | `string` | Yes | n/a |
| status | Access key status (Active or Inactive) | `string` | No | `"Active"` |

### policies object

| Attribute | Description | Type | Required | Default |
|-----------|-------------|------|----------|---------|
| name | Policy name | `string` | Yes | n/a |
| path | Path for the policy | `string` | No | `null` |
| description | Policy description | `string` | No | `null` |
| tags | Tags to assign to the policy | `map(any)` | No | `null` |
| statements | List of policy statements | `list(object)` | Yes | n/a |

### statements object

| Attribute | Description | Type | Required | Default |
|-----------|-------------|------|----------|---------|
| sid | Statement ID | `string` | No | `null` |
| effect | Allow or Deny | `string` | No | `"Allow"` |
| actions | List of IAM actions | `list(string)` | No | `[]` |
| resources | List of resource ARNs | `list(string)` | No | `["*"]` |
| principals | List of principals | `list(object)` | No | `[]` |

### principals object

| Attribute | Description | Type | Required | Default |
|-----------|-------------|------|----------|---------|
| type | Principal type (e.g., AWS, Service) | `string` | Yes | n/a |
| identifiers | List of principal identifiers | `list(string)` | Yes | n/a |

## Outputs

This module does not have any outputs.
