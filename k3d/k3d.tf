locals {
  image              = "rancher/k3s:v${var.kubernetes_version}-k3s1"
  config_file        = "config.yaml"
  registry_name      = "${var.cluster_name}.localhost"
  registry_host_name = "k3d-${local.registry_name}"
  registries         = var.create_docker_registry ? ["${local.registry_host_name}:${var.registry_port}"] : []
  scripts_path       = "${path.root}/scripts/${var.cluster_name}"
}

resource "local_file" "cluster_config" {
  filename = "${local.scripts_path}/${local.config_file}"
  content = yamlencode({
    apiVersion = "k3d.io/v1alpha2"
    kind       = "Simple"
    name       = var.cluster_name
    servers    = var.server_count
    agents     = var.node_count
    image      = local.image
    registries = {
      use = local.registries
    }
    options = {
      kubeconfig = {
        updateDefaultKubeconfig = false
        switchCurrentContext    = false
      }
    }
  })
}

resource "local_file" "create_cluster_script" {
  filename = "${local.scripts_path}/create_cluster"

  content = templatefile("${path.module}/templates/create_cluster", {
    config_path     = local.config_file
    cluster_name    = var.cluster_name
    kubeconfig_path = local.kubeconfig_path
  })
}

resource "local_file" "destroy_cluster_script" {
  filename = "${local.scripts_path}/destroy_cluster"

  content = templatefile("${path.module}/templates/destroy_cluster", {
    cluster_name    = var.cluster_name
    node_count      = var.node_count
    kubeconfig_path = local.kubeconfig_path
  })
}

resource "local_file" "destroy_registry_script" {
  count    = var.create_docker_registry ? 1 : 0
  filename = "${local.scripts_path}/destroy_registry"

  content = templatefile("${path.module}/templates/destroy_registry", {
    registry_name = local.registry_host_name
  })
}

resource "local_file" "tmuxp_config" {
  filename = pathexpand("~/.tmuxp/${var.cluster_name}.yaml")

  content = yamlencode({
    session_name = var.cluster_name
    panes        = []

    windows = [
      {
        window_name = "default"
    }]

    environment = {
      KUBECONFIG = pathexpand(local.kubeconfig_path)
    }
  })
}

resource "null_resource" "k3d_registry" {
  count = var.create_docker_registry ? 1 : 0
  depends_on = [
    local_file.destroy_registry_script
  ]

  triggers = {
    working_dir = local.scripts_path
  }

  provisioner "local-exec" {
    command = "k3d registry create ${local.registry_name} --port ${var.registry_port}"
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "bash destroy_registry"
    working_dir = self.triggers.working_dir
  }
}

resource "null_resource" "k3d_cluster" {
  depends_on = [
    local_file.create_cluster_script,
    local_file.destroy_cluster_script,
    null_resource.k3d_registry,
  ]

  triggers = {
    create_cluster_script = sha256(local_file.create_cluster_script.content)
    working_dir           = local.scripts_path
  }

  provisioner "local-exec" {
    command     = "bash create_cluster"
    working_dir = local.scripts_path
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "bash destroy_cluster"
    working_dir = self.triggers.working_dir
  }
}