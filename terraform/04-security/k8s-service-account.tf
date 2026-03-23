resource "kubernetes_service_account_v1" "secrets_reader" {

  metadata {

    name      = "secrets-reader"
    namespace = "default"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_secrets_role.arn
    }
  }
}

resource "kubernetes_service_account_v1" "alb_sa" {

  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller_role.arn
    }
  }
}