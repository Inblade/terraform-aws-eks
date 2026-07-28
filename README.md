# terraform-aws-eks

Reference Terraform modules for a production-grade Amazon EKS platform, distilled from patterns I have run in production. This is not a company repository - it is a clean-room template you can fork and adapt.

## What you get

- **3-AZ VPC** purpose-built for EKS: private subnets for nodes, public subnets for load balancers, one NAT gateway per AZ (single-NAT mode available for non-prod), and the subnet tags required by the AWS Load Balancer Controller.
- **EKS cluster** with:
  - managed node groups (`for_each` map, on-demand and spot, labels/taints, `desired_size` drift ignored so cluster-autoscaler stays in control)
  - IRSA via an IAM OIDC provider
  - cluster-autoscaler auto-discovery tags applied to the node group ASGs with `aws_autoscaling_group_tag` (managed node groups do not propagate them)
  - secrets envelope encryption with a rotating KMS key
  - core addons: vpc-cni, coredns, kube-proxy, and the EBS CSI driver with its own IRSA role
  - private API endpoint by default, control-plane logs to CloudWatch

## Structure

```
.
├── modules/
│   ├── vpc/                 # 3-AZ network layer
│   │   ├── main.tf
│   │   └── variables.tf
│   └── eks/                 # cluster, node groups, IRSA, addons
│       ├── main.tf
│       └── variables.tf
├── environments/
│   └── prod/
│       ├── main.tf          # composes vpc + eks
│       └── versions.tf      # providers, backend
├── LICENSE
└── README.md
```

## Usage

```bash
cd environments/prod

# Point versions.tf at your own state bucket/lock table first.
terraform init
terraform plan -out plan.out
terraform apply plan.out

aws eks update-kubeconfig --name prod-main --region us-east-1
```

Adding an environment is a new directory under `environments/` that composes the same modules with different sizing - the modules themselves never change per environment.

## Requirements

| Component | Version |
|-----------|---------|
| Terraform | >= 1.9 |
| hashicorp/aws | ~> 5.100 |
| hashicorp/tls | ~> 4.0 |
| Kubernetes | 1.33 (configurable) |

## Design notes

- The API endpoint is private-only; reach it through a VPN or bastion inside the VPC. Flip `endpoint_public_access` with an allow-list of CIDRs only if you accept the trade-off.
- Spot node groups carry a taint so only workloads that tolerate interruption land there.
- `authentication_mode = "API_AND_CONFIG_MAP"` keeps aws-auth compatibility while letting you migrate to EKS access entries incrementally.
- IRSA roles for workloads (external-dns, cert-manager, cluster-autoscaler itself) are intentionally out of scope here - consume `oidc_provider_arn` / `oidc_issuer_url` outputs from your workload stacks.

## License

MIT - see [LICENSE](LICENSE).
