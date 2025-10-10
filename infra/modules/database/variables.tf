variable "env" {
  description = "Environnement (dev, prod, etc.)"
  type        = string
}

variable "region" {
  description = "Région GCP où déployer la base"
  type        = string
}

variable "db_name" {
  description = "Nom de la base de données"
  type        = string
}

variable "db_username" {
  description = "Nom d'utilisateur PostgreSQL"
  type        = string
}

variable "db_password" {
  description = "Mot de passe PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_tier" {
  description = "Type de machine CloudSQL"
  type        = string
  default     = "db-f1-micro"
}

variable "authorized_networks" {
  description = "Liste des IP autorisées à se connecter à la base"
  type = list(object({
    name = string
    value = string
  }))
  default = []
}