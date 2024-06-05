# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  version                    = "~> 30.0"
  project_id                 = var.project_id
  name                       = "${var.cluster_name}-${var.env_name}"
  regional                   = true
  region                     = var.region
  zones                      = var.zones
  network                    = module.gcp-network.network_name
  subnetwork                 = module.gcp-network.subnets_names[0]
  ip_range_pods              = var.ip_range_pods_name
  ip_range_services          = var.ip_range_services_name
  http_load_balancing        = true
  network_policy             = false
  horizontal_pod_autoscaling = false
  filestore_csi_driver       = true
  create_service_account     = true
  deletion_protection        = false
  remove_default_node_pool   = true
  logging_service            = "logging.googleapis.com/kubernetes"

  node_pools = [
    {
      name            = "workers"
      machine_type    = var.machine_type
      min_count       = 1
      max_count       = 5
      disk_size_gb    = 40
      spot            = false
      auto_upgrade    = true
      auto_repair     = true
      autoscaling     = true
      service_account = var.service_account
    },

    {
      name            = "monitoring"
      machine_type    = var.machine_type
      min_count       = 1
      max_count       = 1
      disk_size_gb    = 60
      spot            = false
      auto_upgrade    = true
      auto_repair     = true
      autoscaling     = false
      service_account = var.service_account
    },
  ]


  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/servicecontrol",
    ]
  }

  node_pools_labels = {
    workers = {
      workers = true
    }

    monitoring = {
      monitoring = true
    }
  }

  node_pools_metadata = {
    all = {
      shutdown-script = "kubectl --kubeconfig=/var/lib/kubelet/kubeconfig drain --force=true --ignore-daemonsets=true --delete-local-data \"$HOSTNAME\""
    }
  }


  node_pools_tags = {
    workers = [
      "workers",
    ]

    monitoring = [
      "monitoring",
    ]

  }

  node_pools_taints = {
    monitoring = [
      {
        key    = "monitoring"
        value  = true
        effect = "NO_EXECUTE"
      },
    ]  
  }

  depends_on = [
    module.gcp-network
  ]
}