terraform {
  required_version = ">= 1.3, < 2.0"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 4"
    }
  }
}
