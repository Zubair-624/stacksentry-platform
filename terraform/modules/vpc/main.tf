#----------VPC---------- 
resource "aws_vpc" "vpc" {

    tags = {
        Name = "${var.project_name}-vpc"
        Environment = var.environment
    }

    cidr_block = var.aws_vpc_cidr_block

    # Allows resources INSIDE the VPC to look up domain names ("google.com" -> 142.250.80.46)
    enable_dns_support = true 

    # Gives each EC2 instance inside VPC an automatic DNS name ("ec2-10-0-1-45.compute.amazonaws.com")
    enable_dns_hostnames = true 

}

#----------IGW----------
resource "aws_internet_gateway" "igw" {

    tags = {
      Name = "${var.project_name}-igw"
      Environment = var.environment
    }

    vpc_id = aws_vpc.vpc.id
  
}

#----------Public Subnet----------
resource "aws_subnet" "public_subnets" {

    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "${var.project_name}-public-subnet-${count.index + 1}"
        Environment = var.environment
    }

    availability_zone = var.azs[count.index]

    cidr_block = var.public_subnet_cidrs[count.index]

    # EC2 gets public IP -> internet can reach it 
    map_public_ip_on_launch = true 

    count = length(var.public_subnet_cidrs)
  
}

#----------Private Subnet----------
resource "aws_subnet" "private_subnets" {

    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "${var.project_name}-private-subnet-${count.index + 1}"
        Tier = "private"
        Environment = var.environment
    }

    availability_zone = var.azs[count.index]

    cidr_block = var.private_subnet_cidrs[count.index]

    map_public_ip_on_launch = false 

    count = length(var.private_subnet_cidrs)
  
}

#----------Elastic IPs for NAT----------
# If single_nat_gateway = true  -> creates 1 EIP only
# If single_nat_gateway = false -> creates 1 EIP per AZ
resource "aws_eip" "nat_eips" {

    # Means: This Elastic IP is for VPC use
    # Used INSIDE a VPC (modern way, what we need)
    domain = "vpc"

    tags = {
        Name = "${var.project_name}-nat-eip-${count.index + 1}"
        Environment = var.environment
    }

    count = var.single_nat_gateway ? 1 : length(var.azs)
  
}

#----------NAT Gateway----------
resource "aws_nat_gateway" "nat_gateways" {

    tags = {
        Name = "${var.project_name}-nat-gateway-${count.index + 1}"
        Environment = var.environment
    }

    subnet_id = aws_subnet.public_subnets[count.index].id

    # This NAT Gateway faces the public internet
    connectivity_type = "public"

    allocation_id = aws_eip.nat_eips[count.index].id

    # explicit dependency
    # NAT Gateway ALWAYS needs IGW to exist first
    depends_on = [ aws_internet_gateway.igw ]

    # true -> count = 1 -> 1 NAT Gateway created
    # false -> count = length(var.azs) -> 3 NAT Gateways created
    count = var.single_nat_gateway ? 1 : length(var.azs)
  
}

#----------Public Route Table----------
# Route Table = A set of rules that tells network traffic WHERE to go
resource "aws_route_table" "public_rt" {

    tags = {
        Name = "${var.project_name}-public-rt"
        Environment = var.environment
    }

    vpc_id = aws_vpc.vpc.id 

    # All traffic → Internet Gateway -> Internet directly
    route {
        #"ALL traffic" or "every IP address on the internet"
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id 
    }
  
}

#----------Route Table Association (Public Route Table + Public Subnet)----------
resource "aws_route_table_association" "public" {

    route_table_id = aws_route_table.public_rt.id

    subnet_id = aws_subnet.public_subnets[count.index].id

    count = length(var.azs)
  
}

#----------Private Route Tables----------
# If single_nat_gateway = true -> all private subnets route through 1 NAT Gateway
# If single_nat_gateway = false -> each private subnet routes through its own NAT Gateway
resource "aws_route_table" "private_rt" {

    tags = {
        Name = "${var.project_name}-private-rt"
        Environment = var.environment
    }

    vpc_id = aws_vpc.vpc.id

    # "All traffic → NAT Gateway -> Internet indirectly"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.nat_gateways[0].id : aws_nat_gateway.nat_gateways[count.index].id 
    }

    count = length(var.azs)
  
}

#----------Route Table Association (Private Route Table + Private Subnet)----------
resource "aws_route_table_association" "private" {

    route_table_id = aws_route_table.private_rt[count.index].id

    subnet_id = aws_subnet.private_subnets[count.index].id

    count = length(var.azs)
  
}