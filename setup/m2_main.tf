resource "aws_security_group" "web" {
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = "" # 8080 for production, 80 for non-production
    to_port     = "" # 8080 for production, 80 for non-production
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = format("%s-web-sg", local.name_prefix)
  })
}

data "aws_ssm_parameter" "amazon_linux_2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2_ami.value
  instance_type               = "" # t3.small for production, t3.micro for non-production
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  monitoring                  = null # true for production, false for non-production
  user_data                   = "" # rendered template with project, environment, team, company variables

  tags = merge(local.common_tags, {
    Name = format("%s-web-instance", local.name_prefix)
    Backup      = "" # "Daily" for production, "Weekly" for non-production
  })
  
}
