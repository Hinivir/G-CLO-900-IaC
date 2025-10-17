# 1. Create a Cloud SQL instance
resource "google_sql_database_instance" "db_instance" {
  name             = "example-instance"
  region           = var.region
  database_version = "POSTGRES_15"

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "all"
        value = "0.0.0.0/0" # ⚠️ For demo only, restrict in production
      }
    }
  }
}

resource "google_sql_database" "app_db" {
  name     = "app_db"
  instance = google_sql_database_instance.db_instance.name
}

resource "google_sql_user" "db_user" {
  name     = "app_user"
  instance = google_sql_database_instance.db_instance.name
  password = var.db_password
}

output "db_connection_name" {
  value = google_sql_database_instance.db_instance.connection_name
}

resource "random_password" "db_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}