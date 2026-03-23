resource "aws_db_instance" "postgres" {
  identifier = "app-postgres-db"

  engine         = "postgres"
  engine_version = "15"

  instance_class = "db.t3.micro" # free-tier eligible

  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "appdb"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.rds_subnets.name

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]

  publicly_accessible = false

  skip_final_snapshot = true

  # Free tier allows max 1 day backup retention
  backup_retention_period = 1

  multi_az            = false
  storage_encrypted   = true
  deletion_protection = false

  tags = {
    Name        = "app-postgres-db"
    Environment = "dev"
  }
}
