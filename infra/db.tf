resource "random_password" "db_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "google_sql_database_instance" "db_instance" {
  name             = var.db_name
  region           = var.region
  database_version = "POSTGRES_15"

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = true
    }
  }
}

resource "google_sql_user" "db_user" {
  name     = var.db_username
  instance = google_sql_database_instance.db_instance.name
  password = random_password.db_password.result
}

resource "google_secret_manager_secret" "db_secret" {
  secret_id = "db-username"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db_secret_version" {
  secret      = google_secret_manager_secret.db_secret.id
  secret_data = var.db_username
}

resource "google_secret_manager_secret" "db_password_secret" {
  secret_id = "db-password"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db_password_secret_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = random_password.db_password.result
}

resource "google_secret_manager_secret" "db_connection_name_secret" {
  secret_id = "db-connection-name"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db_connection_name_secret_version" {
  secret      = google_secret_manager_secret.db_connection_name_secret.id
  secret_data = google_sql_database_instance.db_instance.connection_name

  depends_on = [ google_sql_database_instance.db_instance ]
}

resource "google_secret_manager_secret" "db_name_secret" {
  secret_id = "db-name"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db_name_secret_version" {
  secret      = google_secret_manager_secret.db_name_secret.id
  secret_data = var.db_name
}

output "db_connection_name" {
  value = google_sql_database_instance.db_instance.connection_name
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}
