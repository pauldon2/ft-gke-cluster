#GCP
terraform {
  required_version = ">= 1.2.0, <= 1.6.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "< 6.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "google" {
  #  credentials = file("./sa-iac-manager.json")
  project = var.project_id
  region  = var.region
  zone    = join("-", [var.region, "STRING", var.zone])

}

terraform {
  backend "gcs" {
    bucket = "plab-state"
    prefix = "terraform/prom-4monitor-dev.tfstate"
  }
}



