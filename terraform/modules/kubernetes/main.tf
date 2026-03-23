# Ensure kube-system namespace exists
data "kubernetes_namespace" "kube_system" {
  metadata {
    name = "kube-system"
  }
}

# Secrets Store CSI Driver
resource "helm_release" "secrets_store" {
  name       = "secrets-store"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = data.kubernetes_namespace.kube_system.metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      installCRDs = true
      linux = {
        resources = {
          limits   = { cpu = "100m", memory = "128Mi" }
          requests = { cpu = "50m", memory = "64Mi" }
        }
      }
    })
  ]

  atomic  = true
  cleanup_on_fail  = true
  wait    = true
  timeout = 600
}

# AWS Secrets Provider for CSI (with its own ServiceAccount)
# resource "helm_release" "secrets_provider_aws" {
#   name       = "secrets-provider-aws"
#   repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
#   chart      = "secrets-store-csi-driver-provider-aws"
#   namespace  = kubernetes_namespace.kube_system.metadata[0].name
#
#   values = [
#     yamlencode({
#       resources = {
#         limits   = { cpu = "100m", memory = "128Mi" }
#         requests = { cpu = "50m", memory = "64Mi" }
#       }
#     })
#   ]
#
#   atomic  = true
#   wait    = true
#   timeout = 300
#
#   depends_on = [
#     helm_release.secrets_store,
#     kubernetes_namespace.kube_system
#   ]
# }

# kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml

# AWS Load Balancer Controller service account
resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = data.kubernetes_namespace.kube_system.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = var.alb_role_arn
    }
  }
}

# AWS Load Balancer Controller Helm release
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = data.kubernetes_namespace.kube_system.metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region      = var.region
      vpcId       = var.vpc_id

      serviceAccount = {
        create = false
        name   = "aws-load-balancer-controller"
      }

      controller = {
        resources = {
          limits   = { cpu = "100m", memory = "128Mi" }
          requests = { cpu = "50m", memory = "64Mi" }
        }
      }

      replicaCount = 1
    })
  ]

  atomic  = true
  cleanup_on_fail  = true
  wait    = true
  timeout = 300

  depends_on = [
  kubernetes_service_account.alb_controller,
  helm_release.secrets_store,
  ]
}

# Metrics Server
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = data.kubernetes_namespace.kube_system.metadata[0].name
  create_namespace = false
  version    = "3.13.0"

  values = [
    yamlencode({
      args = [
        "--kubelet-insecure-tls",
        "--kubelet-preferred-address-types=InternalIP"
      ]
      resources = {
        limits   = { cpu = "100m", memory = "128Mi" }
        requests = { cpu = "50m", memory = "64Mi" }
      }
    })
  ]

  atomic  = true
  cleanup_on_fail  = true
  wait    = true
  timeout = 300

  depends_on = [
    helm_release.alb_controller,
  ]
}
