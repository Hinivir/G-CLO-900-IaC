resource "google_container_cluster" "primary" {
    name                     = var.cluster_name
    location                 = var.cluster_location
    remove_default_node_pool = true
    initial_node_count       = 1
    network                  = google_compute_network.vpc.self_link
    subnetwork               = google_compute_subnetwork.subnet.self_link
    networking_mode          = "VPC_NATIVE"
}

resource "google_container_node_pool" "primary_nodes" {
  cluster    = google_container_cluster.primary.name
  location   = var.cluster_location
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}