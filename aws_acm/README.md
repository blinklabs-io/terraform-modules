# AWS ACM

This module creates and validates ACM (AWS Certificate Manager) certificates using DNS validation with Route53. It automatically creates the required Route53 validation records and waits for certificate validation to complete.

## Usage

```hcl
module "acm" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git//aws_acm?ref=aws_acm/v0.1.0"

  certificates = [
    {
      name           = "example.com"
      route53_domain = "example.com"
    },
    {
      name           = "api.example.com"
      route53_domain = "example.com"
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

| Name | Description | Type | Required |
|------|-------------|------|----------|
| certificates | List of ACM certificates to manage | `list(object({ name = string, route53_domain = string }))` | Yes |

### Certificate Object

| Attribute | Description | Type |
|-----------|-------------|------|
| name | The domain name for the certificate (e.g., "example.com" or "*.example.com") | `string` |
| route53_domain | The Route53 hosted zone domain name used for DNS validation | `string` |

## Outputs

This module does not define any outputs.
