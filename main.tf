terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
  backend "gcs" {

  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "main" {
  name = var.vpc_name
}

resource "google_compute_subnetwork" "main" {
  name          = var.subnet_name
  network       = google_compute_network.main
  ip_cidr_range = var.cidr_block
  region        = var.region
}