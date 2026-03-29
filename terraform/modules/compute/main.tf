# Fetch current public IP dynamically
data "http" "myip" {
  url = "https://checkip.amazonaws.com/"
}

# Security Groups
# Jenkins SG
resource "aws_security_group" "jenkins_sg" {
  name   = "jenkins-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH (restricted to admin IP)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [chomp(data.http.myip.body)]
  }

  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# Ansible SG
resource "aws_security_group" "ansible_sg" {
  name   = "ansible-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH (restricted to admin IP)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [chomp(data.http.myip.body)]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ansible-sg"
  }
}

# Key Pair
resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = file("${path.module}/../../bastion_key.pub")
}

# IAM Role for Jenkins EC2
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Policies (modularized)

# Pipeline operations (Terraform state + EKS dynamic ops)
resource "aws_iam_role_policy" "jenkins_pipeline" {
  name = "jenkins-pipeline"
  role = aws_iam_role.jenkins_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject","s3:PutObject","s3:DeleteObject","s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::devops-eks-terraform-state-15-03", #bucket‑level operations
          "arn:aws:s3:::devops-eks-terraform-state-15-03/*" #object‑level operations
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["dynamodb:GetItem","dynamodb:PutItem","dynamodb:DeleteItem","dynamodb:DescribeTable"],
        Resource = "arn:aws:dynamodb:ap-south-1:149903054702:table/terraform-lock-table"
      },
      {
        Effect   = "Allow",
        Action   = ["eks:ListClusters","eks:DescribeCluster","eks:ListNodegroups","eks:DescribeNodegroup"],
        Resource = "*"
      }
    ]
  })
}

# Monitoring + Notifications
resource "aws_iam_role_policy" "jenkins_monitoring" {
  name = "jenkins-monitoring"
  role = aws_iam_role.jenkins_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["cloudwatch:GetMetricData","cloudwatch:ListMetrics","cloudwatch:GetMetricStatistics"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = "*"
      }
    ]
  })
}

# Instance Profile
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-profile"
  role = aws_iam_role.jenkins_role.name

  lifecycle {
    ignore_changes = [name]
  }
}

# EC2 Instances
# Jenkins EC2
resource "aws_instance" "jenkins_host" {
  ami                    = var.ami_id
  instance_type          = var.jenkins_instance_type
  subnet_id              = var.public_subnets[0]
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name

  tags = {
    Name = "jenkins-server"
  }
}

# Ansible EC2
resource "aws_instance" "ansible_host" {
  ami                    = var.ami_id
  instance_type          = var.ansible_instance_type
  subnet_id              = var.public_subnets[1]
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]

  tags = {
    Name = "ansible-server"
  }
}