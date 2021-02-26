output "name" {
  value = var.cluster_name
}

output "cluster_name" {
  value = "k3d-${var.cluster_name}"
}

output "kube_config" {
  value = pathexpand(local.kubeconfig_path)
}

output "registry_name" {
  value = "${local.registry_host_name}:${var.registry_port}"
}

output "registry_usage" {
  value = templatefile("${path.module}/templates/usage.txt", {
    registry_name = local.registry_host_name
    registry_port = var.registry_port
  })
}