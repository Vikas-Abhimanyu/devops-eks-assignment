resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "eks-node-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when EKS node CPU exceeds 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}