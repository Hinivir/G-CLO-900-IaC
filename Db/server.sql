module "cloudsql" {
  source               = "GoogleCloudPlatform/sql/google"
  version              = "~> 15.0"
  project_id           = "g-clo-900"
  region               = "europe-west9"
  zone                 = "europe-west9-a"
  name                 = "to-do-list-db"
  database_version     = "POSTGRES_15"
  tier                 = "db-f1-micro" # À adapter selon la charge
  availability_type    = "REGIONAL"    # Pour la haute disponibilité
  disk_type            = "PD_SSD"
  disk_size            = 20
  deletion_protection  = true          # Empêche la suppression accidentelle

  # Réseau
  ip_configuration = {
    ipv4_enabled    = false            # Désactive l'IP publique
    private_network = "projects/g-clo-900/global/networks/mon-vpc"
    require_ssl     = true             # Force SSL pour les connexions
  }
}
