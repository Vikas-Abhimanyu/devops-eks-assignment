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
      syncSecret = {
        enabled = true
      }
      linux = {
        resources = {
          limits   = { cpu = "100m", memory = "128Mi" }
          requests = { cpu = "50m", memory = "64Mi" }
        }
      }
    })
  ]

  atomic          = true # Rollback on failure to prevent partial installs
  cleanup_on_fail = true # Ensure failed releases are cleaned up for idempotency
  wait            = true # Wait for all resources to be ready before proceeding
  timeout         = 600  # Increase timeout for CRD installation and controller startup
}

# AWS Secrets Provider for CSI (with its own ServiceAccount)
resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "aws-secrets"
      namespace = "default"
    }
    spec = {
      provider   = "aws"
      parameters = {
        region  = var.region
        roleArn = var.irsa_role_arn
        objects = <<EOT
        - objectName: ${var.db_username_secret_arn}
          objectType: secretsmanager
          objectAlias: db_username
        - objectName: ${var.db_password_secret_arn}
          objectType: secretsmanager
          objectAlias: db_password
        - objectName: ${var.api_key_secret_arn}
          objectType: secretsmanager
          objectAlias: api_key
        EOT
      }
      secretObjects = [{
        secretName = "aws-secrets"
        type       = "Opaque"
        data = [
          { objectName = var.db_username_secret_arn, key = "DB_USERNAME" },
          { objectName = var.db_password_secret_arn, key = "DB_PASSWORD" },
          { objectName = var.api_key_secret_arn, key = "API_KEY" }
        ]
      }]
    }
  }

  field_manager {
    name            = "terraform"
    force_conflicts = true
  }
}

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
        "--kubelet-insecure-tls", # Skip TLS verification for kubelet metrics (common in private clusters)
        "--kubelet-preferred-address-types=InternalIP" # Use InternalIP for better compatibility in private subnets
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

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = var.jenkins_role_arn
        username = "jenkins"
        groups   = ["system:masters"]
      }
    ])
  }

  lifecycle {
    ignore_changes = [
      data["mapRoles"] # Ignore changes to mapRoles to prevent Terraform from trying to revert manual updates (like adding Jenkins role)
    ]
  }
}