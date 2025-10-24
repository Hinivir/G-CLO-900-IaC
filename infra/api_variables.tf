# API Configuration Variables

variable "api_namespace" {
  type        = string
  description = "Kubernetes namespace for the API deployment"
  default     = "api"
}

variable "api_service_account_name" {
  type        = string
  description = "Name of the Kubernetes Service Account for the API"
  default     = "api-sa"
}

variable "api_gcp_service_account_id" {
  type        = string
  description = "GCP Service Account ID for the API"
  default     = "api-service-account"
}

variable "api_replicas" {
  type        = number
  description = "Number of API pod replicas"
  default     = 1
}

variable "api_image_repository" {
  type        = string
  description = "Container image repository for the API"
  default     = "gcr.io/cloud-builders/go"
}

variable "api_image_tag" {
  type        = string
  description = "Container image tag for the API"
  default     = "latest"
}

variable "api_image_pull_policy" {
  type        = string
  description = "Image pull policy for the API container"
  default     = "IfNotPresent"
}

variable "api_container_port" {
  type        = number
  description = "Container port for the API"
  default     = 8000
}

variable "api_service_type" {
  type        = string
  description = "Kubernetes Service type for the API"
  default     = "ClusterIP"
}

variable "api_service_port" {
  type        = number
  description = "Kubernetes Service port for the API"
  default     = 8000
}

variable "api_resources_limits_cpu" {
  type        = string
  description = "CPU resource limit for the API container"
  default     = "500m"
}

variable "api_resources_limits_memory" {
  type        = string
  description = "Memory resource limit for the API container"
  default     = "512Mi"
}

variable "api_resources_requests_cpu" {
  type        = string
  description = "CPU resource request for the API container"
  default     = "250m"
}

variable "api_resources_requests_memory" {
  type        = string
  description = "Memory resource request for the API container"
  default     = "256Mi"
}

variable "api_log_level" {
  type        = string
  description = "Log level for the API"
  default     = "info"
}

variable "api_node_selector" {
  type        = map(string)
  description = "Node selector for the API pods"
  default     = {}
}

variable "api_affinity" {
  type        = any
  description = "Affinity rules for the API pods"
  default     = {}
}

variable "api_tolerations" {
  type        = list(any)
  description = "Tolerations for the API pods"
  default     = []
}
