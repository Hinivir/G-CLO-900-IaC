resource "random_password" "grafana_pwd" {
  length  = 16
  special = false
}

# Store Grafana admin username in GCP Secret Manager
resource "google_secret_manager_secret" "grafana_admin_secret" {
  secret_id = "grafana-admin-username"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "grafana_admin_secret_version" {
  secret      = google_secret_manager_secret.grafana_admin_secret.id
  secret_data = var.grafana_admin
}

# Store Grafana admin password in GCP Secret Manager
resource "google_secret_manager_secret" "grafana_password_secret" {
  secret_id = "grafana-admin-password"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "grafana_password_secret_version" {
  secret      = google_secret_manager_secret.grafana_password_secret.id
  secret_data = random_password.grafana_pwd.result
}

locals {
  grafana_admin    = var.grafana_admin
  grafana_password = random_password.grafana_pwd.result
}

# Create GCP Persistent Disk for Grafana
# Reference the existing Grafana persistent disk (managed outside of Terraform)
data "google_compute_disk" "grafana_disk" {
  name = "grafana-persistent-disk"
  zone = var.zone
}

resource "kubernetes_namespace_v1" "data" {
  metadata {
    name = "monitoring"
  }
  depends_on = [time_sleep.wait_for_cluster, google_container_node_pool.application_nodes]
}

# Create a PersistentVolume using the GCP disk
resource "kubernetes_persistent_volume_v1" "grafana_pv" {
  metadata {
    name = "grafana-pv"
  }

  spec {
    storage_class_name = "standard"
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      gce_persistent_disk {
        pd_name = data.google_compute_disk.grafana_disk.name
        fs_type = "ext4"
      }
    }
  }

  depends_on = [time_sleep.wait_for_cluster, kubernetes_namespace_v1.data]
}

# Create a PersistentVolumeClaim for Grafana
resource "kubernetes_persistent_volume_claim_v1" "grafana_pvc" {
  metadata {
    name      = "grafana-pvc"
    namespace = kubernetes_namespace_v1.data.metadata.0.name
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "standard"

    resources {
      requests = {
        storage = "10Gi"
      }
    }

    volume_name = kubernetes_persistent_volume_v1.grafana_pv.metadata.0.name
  }

  timeouts {
    create = "10m"
  }

  depends_on = [kubernetes_persistent_volume_v1.grafana_pv, kubernetes_namespace_v1.data]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = kubernetes_namespace_v1.data.metadata.0.name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "9.4.5"

  values = [
    yamlencode({
      persistence = {
        enabled          = true
        storageClassName = "standard"
        accessModes      = ["ReadWriteOnce"]
        size             = "10Gi"
        existingClaim    = kubernetes_persistent_volume_claim_v1.grafana_pvc.metadata.0.name
      }
      adminUser     = local.grafana_admin
      adminPassword = local.grafana_password
      podSecurityPolicy = {
        enabled = false
      }
      nodeSelector = {
        "cloud.google.com/gke-nodepool" = "application-node-pool"
      }
    })
  ]

  depends_on = [
    time_sleep.wait_for_cluster,
    kubernetes_namespace_v1.data,
    kubernetes_persistent_volume_claim_v1.grafana_pvc,
    random_password.grafana_pwd,
    kubernetes_cluster_role_binding.terraform_admin
  ]
}
