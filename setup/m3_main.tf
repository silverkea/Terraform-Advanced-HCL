locals {
  ingress_rules = [
    {
      from_port   = var.environment == "production" ? 8080 : 80
      to_port     = var.environment == "production" ? 8080 : 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = var.environment == "production" ? 8443 : 443
      to_port     = var.environment == "production" ? 8443 : 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  buckets = ["logs", "app-data", "backups"]
}

resource "aws_s3_bucket" "web" {
  for_each = "" # Set of buckets to create

  bucket_prefix = format("%s-%s-", local.name_prefix, each.value)
  force_destroy = true
  
  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "web" {
  for_each = "" # Set of buckets to create
  bucket = "" # bucket reference

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}