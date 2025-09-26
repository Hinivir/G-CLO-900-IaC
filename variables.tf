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

variable "api_id" {
  type        = string
  description = "Api ID"
}

variable "role_id" {
  type        = string
  description = "Custom IAM Role ID"
}

variable "role_title" {
  type        = string
  description = "Custom IAM Role Title"
}