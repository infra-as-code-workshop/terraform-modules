module "k3d_demo_cluster" {
  source                 = "../k3d"
  cluster_name           = "k3d-demo"
  node_count             = 3
  kubernetes_version     = "1.20.2"
  registry_port          = 5000
  create_docker_registry = false
}

output "kubeconfig" {
  value = "export KUBECONFIG=${pathexpand(module.k3d_demo_cluster.kube_config)}"
}

output "registry" {
  value = ""
}