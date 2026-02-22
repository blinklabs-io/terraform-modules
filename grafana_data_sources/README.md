# Grafana Data Sources

Terraform module for creating Grafana data sources. Supports multiple data sources with optional Private Data Source Connect (PDC) configuration.

## Usage

```hcl
module "grafana_data_sources" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=grafana_data_sources/v0.1.0"

  data_sources = {
    prometheus = {
      type = "prometheus"
      name = "Prometheus"
      url  = "https://prometheus.example.com"
    }
    loki = {
      type = "loki"
      name = "Loki"
      url  = "https://loki.example.com"
      pdc  = "my-pdc-network-id"
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3, < 2.0 |
| grafana | ~> 4 |

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| data_sources | Map of data sources with type, name, URL, and optional PDC configuration. | `map(object({ type = string, name = string, url = string, pdc = optional(string) }))` | Yes | - |

## Outputs

| Name | Description |
|------|-------------|
| uids | Map of data source names to their respective UIDs |
