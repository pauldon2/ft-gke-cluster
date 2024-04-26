#Projet name
variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in"
  default     = ""
}
#GCP Region
variable "region" {
  type        = string
  description = "The region to host the cluster in"
  default     = ""
}
#GCP Zone
variable "zone" {
  description = "GCP Zone"
}

### Common variables

variable "env_name" {
  type        = string
  description = "The environment for the GKE cluster"
  default     = "dev"
}

### Cluster variables
variable "cluster_name" {
  type        = string
  description = "The name for the GKE cluster"
  default     = ""
}
variable "network" {
  type        = string
  description = "The VPC network created to host the cluster in"
  default     = "gke-network-dev"
}
variable "subnetwork" {
  type        = string
  description = "The subnetwork created to host the cluster in"
  default     = "gke-subnet-dev"
}
variable "ip_range_pods_name" {
  type        = string
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods-dev"
}
variable "ip_range_services_name" {
  type        = string
  description = "The secondary ip range to use for services"
  default     = "ip-range-services-dev"
}
variable "zones" {
  type        = list(string)
  description = "The project ID to host the cluster in"
  default     = ["europe-north1-a", "europe-north1-b", "europe-north1-c"]
}

variable "service_account" {
  type        = string
  description = "The service account to run nodes as if not overridden in `node_pools`. The create_service_account variable default value (true) will cause a cluster-specific service account to be created."
}
