# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
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
  logging_service            = "logging.googleapis.com/kubernetes"

  node_pools = [
    {
      name            = var.node_pool_name
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
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}
    node-pool = {
      shutdown-script                 = "kubectl --kubeconfig=/var/lib/kubelet/kubeconfig drain --force=true --ignore-daemonsets=true --delete-local-data \"$HOSTNAME\""
      node-pool-metadata-custom-value = var.node_pool_name
    }
  }

  node_pools_taints = {
    all = []

    node-pool = [
      {
        key    = var.node_pool_name
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []
    node-pool = [
      var.node_pool_name,
    ]
  }
  depends_on = [
    module.gcp-network
  ]
}
