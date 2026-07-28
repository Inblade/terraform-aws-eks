# ---------------------------------------------------------------------------
# Production environment: 3-AZ VPC + EKS cluster with two managed node
# groups (general on-demand, batch spot).
# ---------------------------------------------------------------------------

locals {
  cluster_name = "prod-main"
  azs          = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

module "vpc" {
  source = "../../modules/vpc"

  name         = "prod-main"
  cluster_name = local.cluster_name

  cidr_block           = "10.32.0.0/16"
  azs                  = local.azs
  public_subnet_cidrs  = ["10.32.0.0/20", "10.32.16.0/20", "10.32.32.0/20"]
  private_subnet_cidrs = ["10.32.64.0/18", "10.32.128.0/18", "10.32.192.0/18"]

  # One NAT gateway per AZ - do not economize here in production.
  single_nat_gateway = false
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = local.cluster_name
  cluster_version = "1.33"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  endpoint_public_access = false

  enabled_log_types = ["api", "audit", "authenticator"]

  node_groups = {
    general = {
      instance_types = ["m6i.xlarge", "m5.xlarge"]
      capacity_type  = "ON_DEMAND"
      min_size       = 3
      max_size       = 12
      desired_size   = 3
      labels = {
        "workload-class" = "general"
      }
    }

    batch-spot = {
      instance_types = ["m6i.2xlarge", "m5.2xlarge", "m5a.2xlarge"]
      capacity_type  = "SPOT"
      min_size       = 0
      max_size       = 20
      desired_size   = 0
      labels = {
        "workload-class" = "batch"
      }
      taints = [{
        key    = "workload-class"
        value  = "batch"
        effect = "NO_SCHEDULE"
      }]
    }
  }
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "nat_gateway_public_ips" {
  value = module.vpc.nat_gateway_public_ips
}
