variable "name" {
  description = "Name prefix applied to all VPC resources."
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC. A /16 is recommended to leave headroom for pod-dense EKS subnets."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of exactly three availability zones to spread subnets across."
  type        = list(string)

  validation {
    condition     = length(var.azs) == 3
    error_message = "This module is opinionated about a 3-AZ layout; provide exactly three availability zones."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per AZ."
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets, one per AZ. Sized larger than public subnets because worker nodes and pods live here."
  type        = list(string)
  default     = ["10.0.64.0/18", "10.0.128.0/18", "10.0.192.0/18"]
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway instead of one per AZ. Cheaper, but cross-AZ traffic and a single point of failure - keep false in production."
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Name of the EKS cluster that will run in this VPC. Used for the kubernetes.io/cluster/<name> subnet tags consumed by the AWS load balancer controller."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
