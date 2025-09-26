resource "google_api_gateway_api" "api" {
  provider = google-beta
  api_id   = var.api_id
  project  = var.project_id
}