# Create the isolated namespace for Layer-2 Load Balancing
resource "kubernetes_namespace" "metallb_ns" {
  metadata {
    name = "metallb-system"
  }
}

# Deploy official MetalLB controller and network speaker daemons
resource "helm_release" "metallb" {
  depends_on = [kubernetes_namespace.metallb_ns]
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.14.5"
  namespace  = "metallb-system"
}

# Inject the IP Pool specifications into the cluster API
resource "kubernetes_manifest" "metallb_ip_pool" {
  depends_on = [helm_release.metallb]
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind"       = "IPAddressPool"
    "metadata" = {
      "name"      = "local-ip-pool"
      "namespace" = "metallb-system"
    }
    "spec" = {
      "addresses" = var.metallb_ip_range
    }
  }
}

# Instruct speakers to announce presence via Layer-2 Gratuitous ARP
resource "kubernetes_manifest" "metallb_l2_advertisement" {
  depends_on = [kubernetes_manifest.metallb_ip_pool]
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind"       = "L2Advertisement"
    "metadata" = {
      "name"      = "local-l2-adv"
      "namespace" = "metallb-system"
    }
  }
}

# Deploy foundational Istio CRDs and Ingress control plane
resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "https://istio-release.elasticbeanstalk.com/charts"
  chart            = "base"
  version          = "1.20.0"
  namespace        = "istio-system"
  create_namespace = true
}

resource "helm_release" "istiod" {
  depends_on = [helm_release.istio_base]
  name       = "istiod"
  repository = "https://istio-release.elasticbeanstalk.com/charts"
  chart      = "istiod"
  version    = "1.20.0"
  namespace  = "istio-system"
}

resource "helm_release" "istio_ingress" {
  depends_on = [helm_release.istiod]
  name       = "istio-ingressgateway"
  repository = "https://istio-release.elasticbeanstalk.com/charts"
  chart      = "gateway"
  version    = "1.20.0"
  namespace  = "istio-system"
}

# Bare minimum infra compliance namespace for application isolation & mesh activation
resource "kubernetes_namespace" "app_space" {
  metadata {
    name = var.app_namespace
    labels = {
      "istio-injection" = "enabled"
    }
  }
}