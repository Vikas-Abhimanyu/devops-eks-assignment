# Fetch current public IP dynamically
data "http" "myip" {
  url = "https://checkip.amazonaws.com/"
}

# Security Group for Jenkins/Ansible/SSH
resource "aws_security_group" "devops_sg" {
  name   = "devops-host-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
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
}

# Key pair
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

# Attach ECR PowerUser (push/pull images)
resource "aws_iam_role_policy_attachment" "jenkins_ecr" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "jenkins_eks_cluster" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "jenkins_eks_service" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy" "jenkins_eks_describe" {
  name = "jenkins-eks-describe-cluster"
  role = aws_iam_role.jenkins_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "arn:aws:eks:ap-south-1:149903054702:cluster/devops-eks"
      }
    ]
  })
}

# Instance profile
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-profile"
  role = aws_iam_role.jenkins_role.name

  lifecycle {
    ignore_changes = [name]
  }  
}


# Jenkins EC2
resource "aws_instance" "jenkins_host" {
  ami                    = var.ami_id
  instance_type          = var.jenkins_instance_type
  subnet_id              = var.public_subnets[0]
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  # Attach IAM role via instance profile
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
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  tags = {
    Name = "ansible-server"
  }
}

resource "aws_iam_role_policy" "jenkins_tf_state" {
  name = "jenkins-terraform-state-access"
  role = aws_iam_role.jenkins_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::devops-eks-terraform-state-15-03",
          "arn:aws:s3:::devops-eks-terraform-state-15-03/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ],
        Resource = "arn:aws:dynamodb:ap-south-1:149903054702:table/terraform-lock-table"
      }
    ]
  })
}
