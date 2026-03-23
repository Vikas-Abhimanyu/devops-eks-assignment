resource "aws_cloudwatch_log_group" "eks_cluster_logs" {
  name              = "/aws/eks/${module.eks.cluster_name}/cluster"
  retention_in_days = 7
  tags = {
    Name = "eks-cluster-logs"
  }
}
