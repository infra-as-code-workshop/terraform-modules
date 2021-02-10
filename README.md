# terraform-modules

This repo has collection of terraform modules to support infrastructure as code workshop

## k3d

Terraform module to create local [k3d](https://github.com/rancher/k3d) cluster

### Usage

Create `main.tf`

```hcl
module "k3d_demo_cluster" {
  source                 = "github.com/infra-as-code-workshop/terraform-modules/k3d"
  cluster_name           = "demo"
  node_count             = 3
  kubernetes_version     = "1.20.2"
  registry_port          = 5000
  create_docker_registry = true
}

output "kubeconfig" {
  value = "export KUBECONFIG=${module.k3d_demo_cluster.kube_config}"
}

output "registry_usage" {
  value = module.k3d_demo_cluster.registry_usage
}
```

To create the local cluster using terraform

```bash
terraform init
terraform validate
terraform apply #Use plan if to plan before applying the changes
```