resource "google_sql_database_instance" "this" {
  name             = "${var.env}-postgres-instance"
  region           = var.region
  database_version = "POSTGRES_15"

  settings {
    tier = var.db_tier 
    ip_configuration {
      ipv4_enabled = true
      authorized_networks = var.authorized_networks
    }
    backup_configuration {
      enabled = true
    }
  }

  deletion_protection = false

  depends_on = [google_project_service.sqladmin]
}

resource "google_sql_database" "this" {
  name     = var.db_name
  instance = google_sql_database_instance.this.name
}

resource "google_sql_user" "this" {
  name     = var.db_username
  instance = google_sql_database_instance.this.name
  password = var.db_password
}

resource "google_project_service" "sqladmin" {
  service = "sqladmin.googleapis.com"
  disable_on_destroy = false
}