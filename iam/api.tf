resource "google_api_gateway_api" "api" {
  provider = google-beta
  api_id   = var.api_id
  project  = var.project_id
}

resource "google_project_service" "api_activate_k8s" {
  service = "container.googleapis.com"
  project = var.project_id
}

resource "google_project_service" "api_compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}