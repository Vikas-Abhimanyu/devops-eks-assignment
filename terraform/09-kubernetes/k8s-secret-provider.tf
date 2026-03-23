resource "kubernetes_manifest" "secret_provider" {

  depends_on = [
    helm_release.secrets_store_csi_driver,
    helm_release.aws_secrets_provider
  ]

  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"

    metadata = {
      name      = "aws-secrets"
      namespace = "default"
    }

    spec = {
      provider = "aws"

      parameters = {
        objects = <<EOF
- objectName: "db_username"
  objectType: "secretsmanager"
- objectName: "db_password"
  objectType: "secretsmanager"
- objectName: "api_key"
  objectType: "secretsmanager"
EOF
      }

      secretObjects = [
        {
          secretName = "aws-secrets"
          type       = "Opaque"

          data = [
            {
              objectName = "db_username"
              key        = "db_username"
            },
            {
              objectName = "db_password"
              key        = "db_password"
            },
            {
              objectName = "api_key"
              key        = "api_key"
            }
          ]
        }
      ]
    }
  }
}