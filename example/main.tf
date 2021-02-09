module "k3d_demo_cluster" {
  source                 = "../k3d"
  cluster_name           = "demo"
  node_count             = 3
  kubernetes_version     = "1.20.2"
  registry_port          = 5000
  create_docker_registry = true
}

output "kubeconfig" {
  value = "export KUBECONFIG=${pathexpand(module.k3d_demo_cluster.kube_config)}"
}

output "registry_usage" {
  value = module.k3d_demo_cluster.registry_usage
}