output "vm_ip" {
  value = google_compute_instance.test_vm.network_interface[0].access_config[0].nat_ip
}

output "db_private_ip" {
  value = module.database.db_private_ip
}

output "db_name" {
  value = module.database.db_name
}

output "db_user" {
  value = module.database.db_user
}

output "db_password" {
  value     = module.database.db_password
  sensitive = true
}