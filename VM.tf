resource "google_compute_instance" "test_vm" {
  name         = "test-vm"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.main.id
    subnetwork = google_compute_subnetwork.main_subnet.id

    access_config {}

  metadata = {
    ssh-keys = "terraform:${file("~/.ssh/id_rsa.pub")}"
  }
}