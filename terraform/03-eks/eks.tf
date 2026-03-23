module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.29"

  vpc_id = aws_vpc.main.id

  subnet_ids = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  enable_irsa = true

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # Allow VPC resources (like bastion) to access EKS API
  cluster_security_group_additional_rules = {
    bastion_access = {
      description = "Allow VPC access to EKS API"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["10.0.0.0/16"]
    }
  }

  # Managed Node Group
  eks_managed_node_groups = {
    default = {
      desired_size = 2
      min_size     = 1
      max_size     = 3

      instance_types = ["t3.micro"]

      capacity_type = "ON_DEMAND"
    }
  }

  # Grant cluster admin access to terraform_user
  access_entries = {
    terraform_user_admin = {
      principal_arn = "arn:aws:iam::149903054702:user/terraform_user"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    Project     = "eks-assignment"
  }
}