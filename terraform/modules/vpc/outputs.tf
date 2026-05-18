#----------VPC ID Output----------
output "vpc_id" {

    value = aws_vpc.vpc.id
  
}

#----------Public Subnet IDs Output----------
# Will Used by: Load Balancer, Bastion Host, any internet-facing resource
output "public_subnet_ids" {

    value = aws_subnet.public_subnets[*].id 
  
}

#----------Private Subnet IDs Output----------
# Will Used by: Database, Application servers, any internal resource
output "private_subnet_ids" {

    value = aws_subnet.private_subnets[*].id 
  
}

#----------Nat Gateway IDs Output----------
# Returns all NAT Gateway IDs as a list
# Count depends on -> single_nat_gateway
# true  = returns 1 ID
# false = returns 3 IDs
output "nat_gateway_ids" {

    description = "NAT Gateway IDs"
    value = aws_nat_gateway.nat_gateways[*].id
  
}

#----------NAT Gateway Count Output----------
# Returns how many NAT Gateways were actually created
# Useful for monitoring and cost tracking
# dev/staging = 1
# production  = 3
output "nat_gateway_count" {

    description = "Number of NAT Gateways created"
    value = length(aws_nat_gateway.nat_gateways[*].id)
  
}

#----------Public Route Table Output----------
# Returns the single public route table ID
# No [*] needed because only 1 public route table exists
output "route_table_public_id" {

    description = "Public Route Table ID"
    value = aws_route_table.public_rt.id
  
}

#----------Private Route Tables Output----------
# Returns all private route table IDs as a list
# Always 3 IDs (one per AZ) regardless of single_nat_gateway
# dev/staging = all 3 point to same NAT GW
# production  = each points to own NAT GW
output "private_route_table_ids" {

  description = "Private route table IDs"

  value = aws_route_table.private_rt[*].id 
}




#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
# This is for my future remember:
# output "nat_gateway_ids" {
#     value       = aws_nat_gateway.nat_gateways[*].id
#     description = "NAT Gateway IDs"
# }

# ---This output CHANGES based on environment:---
# DEV (single_nat_gateway = true):
# nat_gateway_ids = [
#     "nat-0aaa111"    ← only 1 exists
# ]

# PROD (single_nat_gateway = false):
# nat_gateway_ids = [
#     "nat-0aaa111",   ← NAT GW 1 (us-east-1a)
#     "nat-0bbb222",   ← NAT GW 2 (us-east-1b)
#     "nat-0ccc333"    ← NAT GW 3 (us-east-1c)
# ]

#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
# output "nat_gateway_count" {
#     value       = length(aws_nat_gateway.nat_gateways[*].id)
#     description = "Number of NAT Gateways created"
# }

# --This is a NEW output. Breaking it down---
# aws_nat_gateway.nat_gateways[*].id
# → gets ALL NAT Gateway IDs as a list

# length(...)
# → counts how many items in that list

# So:
# DEV:  length(["nat-0aaa111"])                          = 1
# PROD: length(["nat-0aaa111", "nat-0bbb222", "nat-0ccc333"]) = 3

# ---Why is this useful?---
# Other modules can check how many NAT GWs exist:

# dev/staging:
# nat_gateway_count = 1
# → monitoring sets up 1 alarm
# → billing tracks 1 NAT GW cost

# production:
# nat_gateway_count = 3
# → monitoring sets up 3 alarms
# → billing tracks 3 NAT GW costs
#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------

# output "private_route_table_ids" {
#     value       = aws_route_table.private_route_tables[*].id
#     description = "Private route table IDs"
# }

# ---This is a NEW output. Always returns 3 IDs---
# DEV (single_nat_gateway = true):
# private_route_table_ids = [
#     "rtb-prv-001",   ← points to nat-0aaa111
#     "rtb-prv-002",   ← points to nat-0aaa111 (same)
#     "rtb-prv-003"    ← points to nat-0aaa111 (same)
# ]

# PROD (single_nat_gateway = false):
# private_route_table_ids = [
#     "rtb-prv-001",   ← points to nat-0aaa111 (own)
#     "rtb-prv-002",   ← points to nat-0bbb222 (own)
#     "rtb-prv-003"    ← points to nat-0ccc333 (own)
# ]




