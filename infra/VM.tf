resource "google_compute_instance" "api_vm" {
  name         = "api-vm"
  machine_type = "e2-micro"
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network       = "default"
    access_config {} # donne une IP publique
  }

  tags = ["api-server"]

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io

    # Télécharge l'image Docker de l'API Go (buildée et pushée avant)
    docker run -d -p 80:18080 gcr.io/${var.project_id}/api:latest
  EOT
}

# Firewall pour autoriser l'accès HTTP
resource "google_compute_firewall" "api_firewall" {
  name    = "allow-api-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = ["api-server"]
  source_ranges = ["0.0.0.0/0"]
}