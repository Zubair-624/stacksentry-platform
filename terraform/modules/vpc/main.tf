#----------VPC---------- 
resource "aws_vpc" "vpc" {

    tags = {
        Name = "${var.project_name}-vpc"
    }

    cidr_block = var.aws_vpc_cidr_block

    # Allows resources INSIDE the VPC to look up domain names ("google.com" -> 142.250.80.46)
    enable_dns_support = true 

    # Gives each EC2 instance inside VPC an automatic DNS name ("ec2-10-0-1-45.compute.amazonaws.com")
    enable_dns_hostnames = true 

}

#----------IGW----------
