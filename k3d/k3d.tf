resource "local_file" "create_cluster" {
  filename = "${path.root}/scripts/create_cluster"
  content = templatefile("${path.module}/templates/create_cluster", {
    cluster_name    = var.cluster_name
    node_count      = var.node_count
    kubeconfig_path = local.kubeconfig_path
  })
}

resource "local_file" "destroy_cluster" {
  filename = "${path.root}/scripts/destroy_cluster"
  content = templatefile("${path.module}/templates/destroy_cluster", {
    cluster_name    = var.cluster_name
    node_count      = var.node_count
    kubeconfig_path = local.kubeconfig_path
  })
}

resource "local_file" "tmuxp_config" {
  filename = pathexpand("~/.tmuxp/${var.cluster_name}.yaml")
  content = yamlencode({
    session_name = var.cluster_name
    windows = [
      {
        window_name = "default"
      }
    ]
    panes : []
    environment = {
      KUBECONFIG = pathexpand(local.kubeconfig_path)
    }
  })
}

resource "null_resource" "k3d_cluster" {
  depends_on = [
    local_file.create_cluster,
    local_file.destroy_cluster
  ]

  triggers = {
    create_cluster_script = sha256(local_file.create_cluster.content)
  }

  provisioner "local-exec" {
    command     = "bash create_cluster"
    working_dir = "${path.root}/scripts"
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "bash destroy_cluster"
    working_dir = "${path.root}/scripts"
  }
}