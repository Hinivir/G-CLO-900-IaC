resource "google_container_cluster" "gke_cluster" {
  name                     = var.cluster-name
  location                 = var.region
  remove_default_node_pool = false
  initial_node_count       = 1

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    enable_node_autoprovisioning = false
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name     = var.node_pool_name
  location = var.zone
  cluster  = google_container_cluster.gke_cluster.name

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  initial_node_count = 1
}