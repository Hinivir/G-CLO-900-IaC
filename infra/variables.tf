variable "project_id" {
  type        = string
  description = "Cloud project ID"
}

variable "region" {
  type        = string
  description = "Region for resources"
}

variable "zone" {
  type        = string
  description = "Zone for resources"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}

variable "subnet_name" {
  type        = string
  description = "Name of the Subnet"

}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "cluster_name" {
  type        = string
  description = "Name of the GKE cluster"
}

variable "cluster_location" {
  type        = string
  description = "Location (region or zone) for the GKE cluster"
}

variable "machine_type" {
  type        = string
  description = "Machine type for the GKE nodes"
}

variable "github_token" {
  type        = string
  description = "GitHub token for authentication"
}

variable "static_ip_name" {
  type        = string
  description = "Name for the static IP address for GKE Ingress"
}

variable "grafana_admin" {
  type        = string
  description = "Admin username for Grafana"
}

variable "db_username" {
  type        = string
  description = "Database username for Cloud SQL"
}

variable "db_name" {
  type        = string
  description = "Name of the Cloud SQL database instance"
}

variable "api_service_account_name" {
  type        = string
  description = "Kubernetes Service Account name for the API"
}

variable "api_gcp_service_account_id" {
  type        = string
  description = "GCP Service Account ID for the API"
}

variable "api_image_repository" {
  type        = string
  description = "Container image repository for the API"
}

variable "api_image_tag" {
  type        = string
  description = "Container image tag for the API"
}
