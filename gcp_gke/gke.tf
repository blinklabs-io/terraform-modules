module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "~> 43.0"

  project_id = var.project_id
  name       = var.cluster_name
  region     = var.region
  zones      = var.zones

  kubernetes_version  = var.cluster_version
  release_channel     = var.release_channel
  deletion_protection = var.deletion_protection

  network           = google_compute_network.this.name
  subnetwork        = google_compute_subnetwork.this.name
  ip_range_pods     = local.pod_range_name
  ip_range_services = local.services_range_name

  # Node service account — externally managed, do not create
  create_service_account = false
  service_account        = local.node_sa_email

  # Add-ons
  http_load_balancing             = var.http_load_balancing
  horizontal_pod_autoscaling      = var.horizontal_pod_autoscaling
  enable_vertical_pod_autoscaling = var.enable_vertical_pod_autoscaling
  network_policy                  = var.network_policy
  dns_cache                       = var.dns_cache
  filestore_csi_driver            = var.filestore_csi_driver
  gce_pd_csi_driver               = var.gce_pd_csi_driver
  gcs_fuse_csi_driver             = var.gcs_fuse_csi_driver
  remove_default_node_pool        = var.remove_default_node_pool

  # Monitoring
  monitoring_enable_managed_prometheus = var.monitoring_enable_managed_prometheus
  monitoring_enabled_components        = var.monitoring_enabled_components
  logging_enabled_components           = var.logging_enabled_components

  # Security
  enable_shielded_nodes      = var.enable_shielded_nodes
  master_authorized_networks = var.master_authorized_networks

  # Maintenance
  maintenance_start_time = var.maintenance_start_time
  maintenance_end_time   = var.maintenance_end_time
  maintenance_recurrence = var.maintenance_recurrence

  node_pools = [
    for np_name, np in var.node_pools : {
      name               = np_name
      machine_type       = np.machine_type
      node_locations     = length(np.zones) > 0 ? join(",", np.zones) : null
      min_count          = np.min_count
      max_count          = np.max_count
      initial_node_count = np.initial_node_count
      disk_size_gb       = np.disk_size_gb
      disk_type          = np.disk_type
      image_type         = np.image_type
      auto_repair        = true
      auto_upgrade       = true
      service_account    = local.node_sa_email
      preemptible        = np.preemptible
      spot               = np.spot
    }
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
  }

  node_pools_labels = merge(
    { all = {} },
    { for np_name, np in var.node_pools : np_name => np.labels }
  )

  node_pools_metadata = {
    all = {}
  }

  node_pools_taints = merge(
    { all = [] },
    { for np_name, np in var.node_pools : np_name => np.taints }
  )

  node_pools_tags = merge(
    { all = [] },
    { for np_name, np in var.node_pools : np_name => np.tags }
  )
}
