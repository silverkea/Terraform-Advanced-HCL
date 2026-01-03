output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}

# Use AWS provider function to parse ARN
output "vpc_arn_components" {
  description = "Parsed components of VPC ARN using provider-defined function"
  value       = provider::aws::arn_parse(aws_vpc.main.arn)
}

output "public_url" {
  description = "Public DNS of the web EC2 instance"
  # value       = "http://${aws_instance.web.public_dns}%{if var.environment == local.env.PRODUCTION}:8080%{endif}"
  value = "http://${aws_lb.web.dns_name}:${var.application_settings.load_balancer_settings.port}"

}

output "public_subnet_arns" {
  description = "ARNs of the public subnets"
  value       = [for subnet in aws_subnet.public : subnet.arn]
}

output "bucket_domain_names" {
  description = "Domain names of the S3 buckets"
  value       = [for bucket in aws_s3_bucket.web : bucket.bucket_domain_name]
}