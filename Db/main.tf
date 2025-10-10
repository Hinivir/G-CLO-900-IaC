terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.8"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# --------------------------------------------------
# Module officiel CloudSQL PostgreSQL
# --------------------------------------------------
module "cloudsql" {
  source               = "GoogleCloudPlatform/sql/google"
  version              = "~> 15.0"
  project_id           = var.project_id
  region               = var.region
  zone                 = var.zone
  name                 = var.db_instance_name
  database_version     = "POSTGRES_15"
  tier                 = var.db_tier
  availability_type    = "REGIONAL"
  disk_type            = "PD_SSD"
  disk_size            = 20
  deletion_protection  = true

  ip_configuration = {
    ipv4_enabled    = false
    private_network = var.private_network
    require_ssl     = true
  }
}

# --------------------------------------------------
# Base de données logique
# --------------------------------------------------
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = module.cloudsql.instance_name
}

# --------------------------------------------------
# Utilisateur PostgreSQL
# --------------------------------------------------
resource "google_sql_user" "user" {
  name     = var.db_user
  password = var.db_password
  instance = module.cloudsql.instance_name
}

# --------------------------------------------------
# (Optionnel) Script SQL d'initialisation
# --------------------------------------------------
# ⚠️ Ce bloc est facultatif : il ne s’exécutera que
# si ton poste ou ton runner CI/CD a accès au réseau privé
resource "null_resource" "init_db" {
  depends_on = [google_sql_database.database]

  provisioner "local-exec" {
    command = "psql 'host=${module.cloudsql.private_ip_address} user=${var.db_user} password=${var.db_password} dbname=${var.db_name} sslmode=require' -f ${path.module}/server.sql"
  }
}