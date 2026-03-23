resource "aws_sns_topic" "alerts" {
  name = "eks-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_alert" {

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"

  endpoint = "vikas.a.s.2426@gmail.com"
}