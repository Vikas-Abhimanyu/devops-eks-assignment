# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Explicit ingress rule for EKS → RDS
resource "aws_security_group_rule" "eks_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.eks_node_group_sg
  security_group_id        = aws_security_group.rds_sg.id
}

# Subnet group for private subnets
resource "aws_db_subnet_group" "rds_subnets" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_subnets
}

# Get DB password from Secrets Manager
data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = var.db_password_secret_arn
}

locals {
  # Decode secret string as JSON, fallback to empty map if not valid JSON
  db_secret_json = try(jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string), {})

  # Always require the key to exist
  db_password = lookup(local.db_secret_json, var.db_password_key, "")
}

# RDS instance
resource "aws_db_instance" "postgres" {
  identifier        = "devops-postgres"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_username
  password = local.db_password

  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  multi_az               = false
  publicly_accessible    = false

  depends_on = [
    data.aws_secretsmanager_secret_version.db_secret,
    aws_security_group_rule.eks_to_rds
  ]
}
