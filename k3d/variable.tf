variable "cluster_name" {
  type = string
}

variable "server_count" {
  type    = number
  default = 1
}

variable "node_count" {
  type = number
}

variable "kubernetes_version" {
  type = string
}

variable "registry_port" {
  type = number
}

variable "create_docker_registry" {
  type    = bool
  default = true
}

variable "tmuxp_environment_variables" {
  type    = map(string)
  default = {}
}