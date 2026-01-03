
locals {
  acl_rules         = csvdecode(file("${path.module}/acl_rules.csv"))
  acl_rules_ingress = {
    for rule in local.acl_rules : rule.priority => rule if rule.direction == "ingress"
  }
  acl_rules_egress  = {
    for rule in local.acl_rules : rule.priority => rule if rule.direction == "egress"
  }
}

# # Network ACL
resource "aws_network_acl" "main" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [for subnet in aws_subnet.public : subnet.id]

  tags = merge(local.common_tags, {
    Name = format("%s-nacl", local.name_prefix)
  })
}

# Inbound rules
resource "aws_network_acl_rule" "ingress" {
  for_each       = local.acl_rules_ingress
  network_acl_id = aws_network_acl.main.id
  rule_number    = (tonumber(each.value.priority) * 100) + 10
  egress         = false                  
  protocol       = each.value.protocol    
  rule_action    = each.value.rule_action 
  cidr_block     = each.value.cidr_block  
  from_port      = each.value.from_port   
  to_port        = each.value.to_port     
}

# Outbound rules
resource "aws_network_acl_rule" "egress" {
  for_each       = local.acl_rules_egress
  network_acl_id = aws_network_acl.main.id
  rule_number    = (tonumber(each.value.priority) * 100) + 10
  egress         = false                  
  protocol       = each.value.protocol    
  rule_action    = each.value.rule_action 
  cidr_block     = each.value.cidr_block  
  from_port      = each.value.from_port   
  to_port        = each.value.to_port     
}
