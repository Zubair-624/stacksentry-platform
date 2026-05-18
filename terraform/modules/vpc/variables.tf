#----------Project Name----------
variable "project_name" {

    description = "Project name used for tagging resources"
    type = string

}

#----------Environment----------
variable "environment" {   
  description = "Environment (dev / staging / prod)"
  type        = string
}

#----------VPC CIDR----------
variable "aws_vpc_cidr_block" {

    description = "CIDR Block for the AWS VPC"
    type = string
    default     = "10.0.0.0/16"

}

# List of AWS data centers to spread resources across (["us-east-1a", "us-east-1b"])
variable "azs" {

    description = "Availability zones"
    type = list(string)
  
}

#----------Public Subnet CIDR----------
# One IP range per AZ for public subnets - count must match azs count
variable "public_subnet_cidrs" {

    description = "Public subnet CIDRs"
    type = list(string)

    # Stops Terraform if number of CIDRs doesn't match number of AZs
    validation {
      condition = length(var.public_subnet_cidrs) == length(var.azs)
      error_message = "Public subnet CIDRs must match AZ count"
    }
  
}

#----------Private Subnet CIDR----------
# One IP range per AZ for private subnets — count must match azs count
variable "private_subnet_cidrs" {

    description = "Private subnet CIDRs"
    type = list(string)

    # Stops Terraform if number of CIDRs doesn't match number of AZs
    validation {
      condition = length(var.private_subnet_cidrs) == length(var.azs)
      error_message = "Private subnet CIDRs must match AZ count"
    }
  
}

# single_nat_gateway = true -> switch ON -> 1 NAT Gateway
# single_nat_gateway = false -> switch OFF -> 3 NAT Gateways
variable "single_nat_gateway" {

    description = "Use single NAT Gateway for cost optimization in dev/staging"
    type        = bool
    default     = false

}





