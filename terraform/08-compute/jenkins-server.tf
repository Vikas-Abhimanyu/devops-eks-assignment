resource "aws_security_group" "jenkins_sg" {

  name   = "jenkins-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "jenkins" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "c7i-flex.large"

  subnet_id = aws_subnet.public_a.id

  key_name = aws_key_pair.bastion_key.key_name

  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name

  vpc_security_group_ids = [
    aws_security_group.jenkins_sg.id
  ]

  tags = {
    Name = "jenkins-server"
  }
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "jenkins_ssh_command" {
  value = "ssh -i bastion_key ubuntu@${aws_instance.jenkins.public_ip}"
}