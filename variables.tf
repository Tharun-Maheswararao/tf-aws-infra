variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "new_ami" {
  description = "AWS new AMI"
  type        = string
}

variable "db_username" {
  description = "Database User"
  type        = string
}

variable "db_password" {
  description = "Database Password"
  type        = string
}

variable "db_name" {
  description = "Database Name"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
}

variable "aws_account_id" {
  description = "AWS ACCOUNT ID"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 Zone ID"
  type        = string
}

variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "subdomain" {
  description = "Subdomain"
  type        = string
}

# variable "key_name" {
#   description = "Key Name"
#   type        = string
# }

variable "vpcs" {
  description = "List of VPCs with their CIDRs and subnet structures"
  type = map(object({
    vpc_cidr             = string
    public_subnet_cidrs  = list(string)
    private_subnet_cidrs = list(string)
  }))
}

variable "profile_hosted_zone_id" {
  description = "Route 53 hosted zone ID for the current profile"
  type        = string
}

variable "profile_domain_name" {
  description = "Domain name for the current profile"
  type        = string
}

# variable "root_hosted_zone_id" {
#   description = "Route 53 hosted zone ID for the root domain."
#   type        = string
# }

# variable "root_domain_name" {
#   description = "Root domain name."
#   type        = string
# }
