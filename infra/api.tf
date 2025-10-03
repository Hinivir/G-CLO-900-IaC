resource "google_api_gateway_api" "api" {
  provider = google-beta
  api_id   = var.api_id
  project  = var.project_id
}

resource "google_api_gateway_api_config" "api_config" {
  provider     = google-beta
  api          = google_api_gateway_api.api.api_id
  api_config_id = "v1"
  project      = var.project_id

  openapi_documents {
    document {
      path     = "openapi.yaml"
      contents = file("${path.module}/openapi.yaml")
    }
  }
}

resource "google_api_gateway_gateway" "api_gateway" {
  provider   = google-beta
  project    = var.project_id
  api        = google_api_gateway_api.api.api_id
  api_config = google_api_gateway_api_config.api_config.id
  gateway_id = "api-gateway"
  region     = var.region
}