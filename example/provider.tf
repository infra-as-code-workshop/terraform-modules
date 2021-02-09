terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.0.2"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.0.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.0.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = module.k3d_demo_cluster.kube_config
  }
}