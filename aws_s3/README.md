# AWS S3

This module manages AWS S3 buckets with support for ACLs, bucket policies, and CORS configuration.

## Usage

```hcl
module "s3" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git//aws_s3?ref=aws_s3/v0.1.0"

  buckets = [
    {
      name = "my-bucket"
      acl  = "private"
      tags = {
        Environment = "production"
      }
    },
    {
      name = "my-public-bucket"
      policy = {
        statements = [
          {
            sid     = "PublicReadGetObject"
            effect  = "Allow"
            actions = ["s3:GetObject"]
            principals = [
              {
                type        = "*"
                identifiers = ["*"]
              }
            ]
          }
        ]
      }
      cors_rules = [
        {
          allowed_headers = ["*"]
          allowed_methods = ["GET", "HEAD"]
          allowed_origins = ["https://example.com"]
          max_age_seconds = 3600
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
| buckets | List of S3 buckets to manage | `list(object({...}))` | Yes | n/a |

### Bucket Object Structure

| Attribute | Description | Type | Required | Default |
|-----------|-------------|------|----------|---------|
| name | The name of the S3 bucket | `string` | Yes | n/a |
| acl | The canned ACL to apply (e.g., "private", "public-read") | `string` | No | `null` |
| tags | A map of tags to assign to the bucket | `map(any)` | No | `null` |
| policy | Bucket policy configuration | `object({...})` | No | `null` |
| cors_rules | List of CORS rules for the bucket | `list(object({...}))` | No | `null` |

### Policy Object Structure

| Attribute | Description | Type | Required | Default |
|-----------|-------------|------|----------|---------|
| statements | List of policy statements | `list(object({...}))` | Yes | n/a |

### Policy Statement Object Structure

| Attribute | Description | Type | Required | Default |
|-----------|-------------|------|----------|---------|
| sid | Statement ID | `string` | No | `null` |
| effect | Effect of the statement | `string` | No | `"Allow"` |
| actions | List of actions | `list(string)` | No | `[]` |
| resources | List of resource ARNs (defaults to bucket and bucket/*) | `list(string)` | No | `null` |
| principals | List of principals | `list(object({...}))` | No | `[]` |

### Principal Object Structure

| Attribute | Description | Type | Required | Default |
|-----------|-------------|------|----------|---------|
| type | Principal type (e.g., "AWS", "Service", "*") | `string` | Yes | n/a |
| identifiers | List of principal identifiers | `list(string)` | Yes | n/a |

### CORS Rule Object Structure

| Attribute | Description | Type | Required | Default |
|-----------|-------------|------|----------|---------|
| allowed_headers | List of allowed headers | `list(string)` | No | `null` |
| allowed_methods | List of allowed HTTP methods | `list(string)` | No | `null` |
| allowed_origins | List of allowed origins | `list(string)` | No | `null` |
| expose_headers | List of headers to expose | `list(string)` | No | `null` |
| max_age_seconds | Time in seconds the browser can cache the preflight response | `number` | No | `null` |

## Outputs

This module does not export any outputs.
