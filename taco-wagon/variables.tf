variable "additional_buckets" {
  description = "Additional S3 bucket names to create"
  type        = list(string)
  default     = []
}

variable "application_settings" {
  description = "Application configuration settings"
  type = object({
    instance_settings = object({
      count                         = number
      instance_type_non_production  = optional(string, "t3.micro")
      instance_type_production      = optional(string, "t3.small")
      port                          = number
      protocol                      = string
      monitoring_enabled_production = optional(bool)
    })
    load_balancer_settings = object({
      port     = number
      protocol = string
    })
    health_check = object({
      path     = string
      port     = number
      protocol = string
    })
  })
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "company" {
  description = "Name of the company"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., development, staging, production)"
  type        = string
  default     = "development"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 3
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = null
}

variable "team" {
  description = "Team responsible for the resources"
  type        = string
  default     = "Platform"
}


