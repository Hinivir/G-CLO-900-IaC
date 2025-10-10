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
<<<<<<< HEAD
=======

variable "api_id" {
  type        = string
  description = "Api ID"
}

variable "cluster_name" {
  type        = string
  description = "Name of the GKE cluster"
}

variable "node_pool_name" {
  type        = string
  description = "Name of the GKE node pool"
}

variable "cluster_location" {
  type        = string
  description = "Location (region or zone) for the GKE cluster"
}

variable "node_count" {
  type        = number
  description = "Number of nodes in the GKE node pool"
}

variable "machine_type" {
  type        = string
  description = "Machine type for the GKE nodes"
}
>>>>>>> 0ea5506 (wip: start terraform of k8s cluster)
