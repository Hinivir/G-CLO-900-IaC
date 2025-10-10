output "db_instance_name" {
  description = "Nom de l'instance CloudSQL"
  value       = module.cloudsql.instance_name
}

output "db_private_ip" {
  description = "Adresse IP privée de la base"
  value       = module.cloudsql.private_ip_address
}

output "db_name" {
  description = "Nom de la base de données"
  value       = google_sql_database.database.name
}

output "db_user" {
  description = "Utilisateur de la base"
  value       = google_sql_user.user.name
}

output "db_password" {
  description = "Mot de passe de la base"
  value       = google_sql_user.user.password
  sensitive   = true
}