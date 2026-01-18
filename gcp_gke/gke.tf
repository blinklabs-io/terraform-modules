module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "~> 35.0"

  project_id = var.project
  name       = var.cluster_name
  region     = var.region
  zones      = var.zones

  kubernetes_version       = var.cluster_version
  release_channel          = "UNSPECIFIED"
  deletion_protection      = false
  remove_default_node_pool = true

  network           = google_compute_network.this.name
  subnetwork        = google_compute_subnetwork.this.name
  ip_range_pods     = "pod-range"
  ip_range_services = "services-range"

  # Features
  http_load_balancing             = true
  horizontal_pod_autoscaling      = true
  network_policy                  = true
  enable_vertical_pod_autoscaling = true

  # Workload identity
  identity_namespace = "${var.project}.svc.id.goog"

  node_pools = [
    for np_name, np_conf in var.node_pools : {
      name               = np_name
      machine_type       = try(np_conf.machine_type, "e2-medium")
      min_count          = try(np_conf.min_count, 0)
      max_count          = try(np_conf.max_count, 3)
      initial_node_count = try(np_conf.initial_node_count, 1)
      disk_size_gb       = try(np_conf.disk_size_gb, 100)
      disk_type          = try(np_conf.disk_type, "pd-balanced")
      image_type         = try(np_conf.image_type, "COS_CONTAINERD")
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = try(np_conf.preemptible, false)
      spot               = try(np_conf.spot, false)
      service_account    = google_service_account.node.email
    }
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = merge(
    { all = {} },
    { for np_name, np_conf in var.node_pools : np_name => try(np_conf.labels, {}) }
  )

  node_pools_taints = merge(
    { all = [] },
    { for np_name, np_conf in var.node_pools : np_name => try(np_conf.taints, []) }
  )

  node_pools_tags = merge(
    { all = [] },
    { for np_name, np_conf in var.node_pools : np_name => try(np_conf.tags, []) }
  )
}
