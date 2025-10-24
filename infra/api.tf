# API Helm Chart Deployment
resource "helm_release" "api" {
  name             = "api"
  repository       = ""
  chart            = file("${path.module}/../API/chart")
  namespace        = kubernetes_namespace.api.metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      replicaCount = 1

      image = {
        repository = var.api_image_repository
        tag        = "latest"
      }

      serviceAccount = {
        create = true
        name   = kubernetes_service_account.api.metadata[0].name
        annotations = {
          "iam.gke.io/gcp-service-account" = google_service_account.api.email
        }
      }
    })
  ]

  depends_on = [
    time_sleep.wait_for_cluster,
    google_service_account_iam_member.api_secrets_accessor
  ]
}

# Kubernetes namespace for API
resource "kubernetes_namespace" "api" {
  metadata {
    name = "api"
    labels = {
      "app.kubernetes.io/name"       = "api"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  depends_on = [time_sleep.wait_for_cluster]
}

# Service Account for API
resource "kubernetes_service_account" "api" {
  metadata {
    name      = var.api_service_account_name
    namespace = kubernetes_namespace.api.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.api.email
    }
  }
}

# Google Service Account for API
resource "google_service_account" "api" {
  account_id   = var.api_gcp_service_account_id
  display_name = "API Service Account"
  project      = data.google_client_config.default.project
}

# Workload Identity binding between KSA and GSA
resource "google_service_account_iam_member" "api_workload_identity" {
  service_account_id = google_service_account.api.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_client_config.default.project}.svc.id.goog[${kubernetes_namespace.api.metadata[0].name}/${kubernetes_service_account.api.metadata[0].name}]"
}

# Grant Secret Accessor role to the Service Account
resource "google_service_account_iam_member" "api_secrets_accessor" {
  service_account_id = google_service_account.api.name
  role               = "roles/secretmanager.secretAccessor"
  member             = "serviceAccount:${google_service_account.api.email}"
}

# Grant Cloud SQL Client role to the Service Account (if using Cloud SQL)
resource "google_service_account_iam_member" "api_cloudsql_client" {
  service_account_id = google_service_account.api.name
  role               = "roles/cloudsql.client"
  member             = "serviceAccount:${google_service_account.api.email}"
}
