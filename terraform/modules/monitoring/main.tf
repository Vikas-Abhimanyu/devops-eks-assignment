# CloudWatch Log Group for EKS container logs
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
  }
}

# CloudWatch Log Group for EKS container logs
resource "aws_cloudwatch_log_group" "eks" {
  name              = var.log_group_name
  retention_in_days = 7
}

resource "helm_release" "fluentbit" {
  name       = "fluent-bit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  namespace  = "kube-system"

  values = [
    yamlencode({
      cloudWatchLogs = {
        enabled         = true
        region          = var.region
        logGroupName    = var.log_group_name
        logStreamPrefix = "fluentbit"
        autoCreateGroup = true
      }

      resources = {
        limits = {
          cpu    = "200m"
          memory = "200Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "100Mi"
        }
      }
    })
  ]

  atomic  = true
  wait    = true
  timeout = 300
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.cluster_name}-alerts"
}

# SNS subscription (email example, replace with your email)
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "vikas.a.s.2426@gmail.com"
}

# CPU Utilization alarm for EKS worker nodes (using EC2 metrics)
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "${var.cluster_name}-${var.node_group_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = 300
  threshold           = var.cpu_alarm_threshold

  dimensions = {
    NodeGroupName = var.node_group_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  treat_missing_data = "notBreaching"

  depends_on = [
    helm_release.fluentbit
  ]
}