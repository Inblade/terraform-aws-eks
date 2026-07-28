variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes minor version for the control plane."
  type        = string
  default     = "1.33"
}

variable "vpc_id" {
  description = "ID of the VPC the cluster runs in."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the control plane ENIs and worker nodes."
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Whether the API server endpoint is reachable from the internet. Keep false and use a bastion/VPN where possible."
  type        = bool
  default     = false
}

variable "endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the public endpoint when it is enabled."
  type        = list(string)
  default     = []
}

variable "enabled_log_types" {
  description = "Control plane log types shipped to CloudWatch."
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "node_groups" {
  description = "Managed node groups keyed by name."
  type = map(object({
    instance_types = list(string)
    capacity_type  = optional(string, "ON_DEMAND")
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = optional(number, 100)
    labels         = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
}

variable "vpc_cni_version" {
  description = "Version of the vpc-cni addon. Leave null to let EKS pick the default for the cluster version."
  type        = string
  default     = null
}

variable "coredns_version" {
  description = "Version of the coredns addon."
  type        = string
  default     = null
}

variable "kube_proxy_version" {
  description = "Version of the kube-proxy addon."
  type        = string
  default     = null
}

variable "ebs_csi_version" {
  description = "Version of the aws-ebs-csi-driver addon."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
