data "aws_caller_identity" "current" {}

locals {
  oidc_provider_url = replace(var.oidc_provider, "https://", "")
}

# IAM Role for Kubernetes service account (IRSA)
resource "aws_iam_role" "secrets_role" {
  name = "eks-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider_url}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider_url}:sub" = "system:serviceaccount:default:secrets-reader",
          "${local.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

# IAM Policy to allow Secrets Manager access for IRSA
resource "aws_iam_role_policy" "eks_secrets_policy" {
  name = "eks-secrets-policy"
  role = aws_iam_role.secrets_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = [
        var.db_username_secret_arn,
        var.db_password_secret_arn,
        var.api_key_secret_arn
      ]
    }]
  })
}

# IAM Role for AWS Load Balancer Controller
resource "aws_iam_role" "alb_controller" {
  name = "eks-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider_url}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider_url}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller",
          "${local.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

# IAM Policy for ALB Controller
resource "aws_iam_policy" "alb_policy" {
  name   = "AWSLoadBalancerControllerPolicy"
  policy = file("${path.module}/../../alb-iam-policy.json")
}

# Attach ALB policy to ALB controller role
resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_policy.arn
}

# Kubernetes Service Account with IRSA annotation
resource "kubernetes_service_account" "secrets_reader" {
  metadata {
    name      = "secrets-reader"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.secrets_role.arn
    }
  }
}

# Attach Secrets Manager policy to Jenkins EC2 role
resource "aws_iam_role_policy" "jenkins_secrets_policy" {
  name = "jenkins-secrets-policy"
  role = "jenkins-ec2-role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = [
        var.db_username_secret_arn,
        var.db_password_secret_arn,
        var.api_key_secret_arn
      ]
    }]
  })
}
