# Load Balancer

resource "aws_lb" "web" {
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.public[*].id

  tags = merge(local.common_tags, {
    Name = format("%s-nlb", local.name_prefix)
  })
}

resource "aws_lb_target_group" "web" {
  port        = var.application_settings.instance_settings.port     # From application config variable
  protocol    = var.application_settings.instance_settings.protocol # From application config variable, should be TCP
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    protocol = var.application_settings.health_check.protocol # From application config variable, should be HTTP
    port     = var.application_settings.health_check.port     # From application config variable
    path     = var.application_settings.health_check.path     # From application config variable
  }

  tags = merge(local.common_tags, {
    Name = format("%s-nlb-tg", local.name_prefix)
  })
}

resource "aws_lb_target_group_attachment" "nlb_targets" {
  count = var.application_settings.instance_settings.count # From application config variable

  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web[count.index].id
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.web.arn
  port              = var.application_settings.load_balancer_settings.port     # From application config variable
  protocol          = var.application_settings.load_balancer_settings.protocol # From application config variable, should be TCP

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}


# EC2 Instances

resource "aws_security_group" "web" {
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
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
  count = var.application_settings.instance_settings.count # From application config variable
  ami   = data.aws_ssm_parameter.amazon_linux_2_ami.value
  instance_type = (var.environment == local.env.PRODUCTION
    ? var.application_settings.instance_settings.instance_type_production
    : var.application_settings.instance_settings.instance_type_non_production
  )
  subnet_id              = aws_subnet.public[count.index % length(aws_subnet.public)].id
  vpc_security_group_ids = [aws_security_group.web.id]
  monitoring = (var.environment == local.env.PRODUCTION
    ? var.application_settings.instance_settings.monitoring_enabled_production
    : false
  )
  user_data = templatefile("templates/user_data.tftpl", {
    team        = var.team
    environment = var.environment
    project     = local.name_prefix
    company     = var.company
    instance    = format("%s-web-instance-%d", local.name_prefix, count.index + 1)
  })

  tags = merge(local.common_tags, {
    Name   = format("%s-web-instance-%d", local.name_prefix, count.index + 1)
    Backup = var.environment == local.env.PRODUCTION ? "Daily" : "Weekly"
  })

}