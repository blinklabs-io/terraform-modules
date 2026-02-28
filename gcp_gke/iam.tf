resource "google_service_account" "node" {
  for_each     = var.node_service_account == null ? toset(["this"]) : toset([])
  account_id   = "${var.cluster_name}-node"
  display_name = "${var.cluster_name} Node Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "node_logging" {
  for_each = var.node_service_account == null ? toset(["this"]) : toset([])
  project  = var.project_id
  role     = "roles/logging.logWriter"
  member   = "serviceAccount:${local.node_sa_email}"
}

resource "google_project_iam_member" "node_monitoring" {
  for_each = var.node_service_account == null ? toset(["this"]) : toset([])
  project  = var.project_id
  role     = "roles/monitoring.metricWriter"
  member   = "serviceAccount:${local.node_sa_email}"
}

resource "google_project_iam_member" "node_monitoring_viewer" {
  for_each = var.node_service_account == null ? toset(["this"]) : toset([])
  project  = var.project_id
  role     = "roles/monitoring.viewer"
  member   = "serviceAccount:${local.node_sa_email}"
}

resource "google_project_iam_member" "node_artifact_registry" {
  for_each = var.node_service_account == null ? toset(["this"]) : toset([])
  project  = var.project_id
  role     = "roles/artifactregistry.reader"
  member   = "serviceAccount:${local.node_sa_email}"
}
