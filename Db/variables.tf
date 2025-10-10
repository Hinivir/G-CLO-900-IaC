variable "project_id" {
  description = "ID du projet GCP"
  type        = string
}

variable "region" {
  description = "Région GCP"
  type        = string
  default     = "europe-west9"
}

variable "zone" {
  description = "Zone GCP"
  type        = string
  default     = "europe-west9-a"
}

variable "private_network" {
  description = "Lien vers le VPC privé (ex: projects/my-project/global/networks/main-vpc)"
  type        = string
}

variable "db_instance_name" {
  description = "Nom de l'instance Cloud SQL"
  type        = string
  default     = "to-do-list-db"
}

variable "db_name" {
  description = "Nom de la base de données"
  type        = string
  default     = "mydb"
}

variable "db_user" {
  description = "Utilisateur PostgreSQL"
  type        = string
  default     = "apiuser"
}

variable "db_password" {
  description = "Mot de passe PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_tier" {
  description = "Type d'instance CloudSQL"
  type        = string
  default     = "db-f1-micro"
}