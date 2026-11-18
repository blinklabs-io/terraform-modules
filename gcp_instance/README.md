# GCP Compute Instance

Terraform module for creating a GCP Compute Engine instance with networking and a static external IP. Supports either using GCP's default network or creating a custom VPC with a dedicated subnet.

## Usage

### Custom VPC (default)

```hcl
module "instance" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=gcp_instance/v0.1.0"

  name         = "my-instance"
  machine_type = "e2-medium"
  project      = "my-gcp-project"
  zone         = "us-central1-a"

  disk_size     = 500
  image         = "ubuntu-os-cloud/ubuntu-2004-lts"
  ip_cidr_range = "10.0.0.0/24"
  tags          = ["http-server", "https-server"]
  allow_ports   = [22, 80, 443]

  service_account_email = "my-sa@my-gcp-project.iam.gserviceaccount.com"

  metadata = {
    ssh-keys = "user:ssh-rsa AAAA..."
  }
}
```

### Default network

```hcl
module "instance" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=gcp_instance/v0.1.0"

  name                = "my-instance"
  machine_type        = "e2-medium"
  project             = "my-gcp-project"
  use_default_network = true
}
```

### Confidential VM

```hcl
module "instance" {
  source = "git::https://github.com/blinklabs-io/terraform-modules.git?ref=gcp_instance/v0.1.0"

  name         = "my-instance"
  machine_type = "n2d-standard-4"
  project      = "my-gcp-project"
  image        = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"

  confidential_instance_type = "SEV"
  shielded_instance_config = {
    enable_secure_boot = true
  }
  spot                = true
  allow_source_ranges = ["203.0.113.0/24"]
}
```

## Requirements

| Name      | Version       |
| --------- | ------------- |
| terraform | >= 1.1, < 2.0 |
| google    | ~> 7          |

## Inputs

| Name                   | Description                                                                      | Type           | Required | Default                             |
| ---------------------- | -------------------------------------------------------------------------------- | -------------- | -------- | ----------------------------------- |
| name                   | Instance and resource name                                                       | `string`       | Yes      | -                                   |
| machine_type           | GCP machine type (e.g., `e2-medium`)                                             | `string`       | Yes      | -                                   |
| project                | GCP project ID                                                                   | `string`       | Yes      | -                                   |
| zone                   | GCP zone for the instance (region is derived automatically)                      | `string`       | No       | `"us-central1-a"`                   |
| disk_size              | Boot disk size in GB                                                             | `number`       | No       | `500`                               |
| image                  | Boot disk image                                                                  | `string`       | No       | `"ubuntu-os-cloud/ubuntu-2004-lts"` |
| tags                   | Network tags for the instance                                                    | `list(string)` | No       | `[]`                                |
| use_default_network    | Use GCP's default network instead of creating a custom VPC                       | `bool`         | No       | `false`                             |
| ip_cidr_range          | Subnet CIDR range for the custom VPC (ignored when `use_default_network = true`) | `string`       | No       | `"10.0.0.0/24"`                     |
| metadata               | Metadata key/value pairs (e.g., ssh-keys, startup-script). Merged with defaults. | `map(string)`  | No       | `{}`                                |
| allow_ports            | TCP ports to allow ingress from 0.0.0.0/0. Only applies to custom VPC.           | `list(number)` | No       | `[22]`                              |
| service_account_email  | Service account email to attach to the instance (omitted if `null`)              | `string`       | No       | `null`                              |
| service_account_scopes | OAuth scopes for the service account                                             | `list(string)` | No       | See below                           |
| allow_source_ranges | Source CIDR ranges allowed by the firewall rule. Only applies to custom VPC. | `list(string)` | No | `["0.0.0.0/0"]` |
| confidential_instance_type | Confidential VM type: `SEV`, `SEV_SNP` or `TDX` (disabled if `null`). Sets `on_host_maintenance = "TERMINATE"`. | `string` | No | `null` |
| shielded_instance_config | Shielded VM settings (`enable_secure_boot`, `enable_vtpm`, `enable_integrity_monitoring`); block omitted if `null` | `object` | No | `null` |
| spot | Run as a Spot VM (preemptible, no automatic restart, `TERMINATE` on host maintenance) | `bool` | No | `false` |
| instance_termination_action | Spot preemption action: `STOP` or `DELETE`. Only used when `spot = true`. | `string` | No | `"STOP"` |

### Default service account scopes

```plain
devstorage.read_only, logging.write, monitoring.write,
service.management.readonly, servicecontrol, trace.append
```

## Outputs

| Name          | Description                                         |
| ------------- | --------------------------------------------------- |
| instance_name | Name of the created compute instance                |
| external_ip   | Static external IP address assigned to the instance |

## Notes

- **Firewall rules**: When using a custom VPC (`use_default_network = false`), a firewall rule is created allowing TCP ingress on `allow_ports` (default: SSH only). Set `allow_ports = []` to disable. Does not apply when using the default network.
- **SSH keys**: Project-wide SSH keys are blocked by default for security. Use the `metadata` variable to set instance-level SSH keys or enable OS Login.
