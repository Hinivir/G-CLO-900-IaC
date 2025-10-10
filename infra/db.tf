module "cloudsql" {
  source               = "GoogleCloudPlatform/sql/google"
  version              = "~> 15.0"
  project_id           = "g-clo-900"
  region               = "europe-west9"
  zone                 = "europe-west9-a"
  name                 = "to-do-list-db"
  database_version     = "POSTGRES_15"
  tier                 = "db-f1-micro"
  availability_type    = "REGIONAL"
  disk_type            = "PD_SSD"
  disk_size            = 20
  deletion_protection  = true

  
  ip_configuration = {
    ipv4_enabled    = false
    private_network = "projects/g-clo-900/global/networks/mon-vpc"
    require_ssl     = true
  }
}

resource "random_password" "db_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

module "db_user" {
  source       = "GoogleCloudPlatform/sql-user/google"
  version      = "~> 5.0"
  project_id   = "g-clo-900"
  instance_name = module.cloudsql.name
  name         = "db_admin"
  password     = random_password.db_password.result
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}