terraform {
  required_version = ">= 1.5.0"
}

variable "kubeconfig_path" {
  type = string
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}