output "db_instance_name" {
  value = google_sql_database_instance.this.name
}

output "db_public_ip" {
  value = google_sql_database_instance.this.public_ip_address
}

output "db_name" {
  value = google_sql_database.this.name
}

output "db_username" {
  value = google_sql_user.this.name
}

output "db_password" {
  value     = google_sql_user.this.password
  sensitive = true
}

output "db_port" {
  value = 5432
}