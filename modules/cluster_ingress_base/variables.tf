variable "metallb_ip_range" {
  type        = list(string)
  description = "The network sub-pool MetalLB is authorized to claim via Layer-2 ARP mappings."
}

variable "app_namespace" {
  type        = string
  description = "Target namespace name for infrastructure compliance and sidecar mesh injection."
  default     = "alumni-portal"
}