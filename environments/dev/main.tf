variable "metallb_ip_range" {
  type = list(string)
}

variable "kubeconfig_path" {
  type = string
}

module "dev_cluster_ingress" {
  source           = "../../modules/cluster_ingress_base"
  metallb_ip_range = var.metallb_ip_range

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}