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
