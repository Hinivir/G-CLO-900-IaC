resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  stack_type    = "IPV4_ONLY"

  network = google_compute_network.main.id

  secondary_ip_range {
    range_name    = "runners-nodes"
    ip_cidr_range = "192.168.0.0/20"
  }

  secondary_ip_range {
    range_name    = "application-nodes"
    ip_cidr_range = "192.168.16.0/20"
  }
}

resource "google_container_cluster" "gke_cluster" {
  name                     = var.cluster_name
  location                 = var.cluster_location
  remove_default_node_pool = true
  network                  = google_compute_network.main.id
  subnetwork               = google_compute_subnetwork.gke_subnet.id
  deletion_protection      = false
  initial_node_count       = 1

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "runners-nodes"
    services_secondary_range_name = "application-nodes"
  }

  monitoring_config {
    managed_prometheus {
      enabled = true
    }
  }

  depends_on = [google_compute_subnetwork.gke_subnet]
}

resource "google_container_node_pool" "runners_nodes" {
  name     = "runners-node-pool"
  location = var.cluster_location
  cluster  = google_container_cluster.gke_cluster.name

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  initial_node_count = 1
}

resource "google_container_node_pool" "application_nodes" {
  name     = "application-node-pool"
  location = var.cluster_location
  cluster  = google_container_cluster.gke_cluster.name

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  initial_node_count = 1
}

resource "kubernetes_cluster_role_binding" "terraform_admin" {
  metadata {
    name = "terraform-admin-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "User"
    name      = "github-terraform@g-clo-900.iam.gserviceaccount.com"
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [
    google_container_cluster.gke_cluster,
    google_container_node_pool.runners_nodes,
    google_container_node_pool.application_nodes
  ]
}

resource "google_compute_address" "nat_ips" {
  count  = 2
  name   = "nat-ip-${count.index}"
  region = var.region
}

resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  network = google_compute_network.main.name
  region  = var.region

}

resource "google_compute_router_nat" "gke_nat" {
  name                               = "gke-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat_ips[*].self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
