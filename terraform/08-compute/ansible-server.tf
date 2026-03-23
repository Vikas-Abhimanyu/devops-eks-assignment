resource "aws_security_group" "ansible_sg" {

  name   = "ansible-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere (or restrict to your IP)"
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

  tags = {
    Name = "ansible-sg"
  }
}

resource "aws_instance" "ansible" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_a.id

  key_name = aws_key_pair.bastion_key.key_name

  vpc_security_group_ids = [
    aws_security_group.ansible_sg.id
  ]

  tags = {
    Name = "ansible-server"
  }
}

output "ansible_ssh_command" {
  value = "ssh -i ~/.ssh/bastion_key ubuntu@${aws_instance.ansible.public_ip}"
}