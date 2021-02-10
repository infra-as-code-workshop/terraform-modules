output "kube_config" {
  value = pathexpand(local.kubeconfig_path)
}

output "registry_usage" {
  value = templatefile("${path.module}/templates/usage.txt", {
    registry_name = local.registry_host_name
    registry_port = var.registry_port
  })
}