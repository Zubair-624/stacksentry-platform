#----------Project Name----------
variable "project_name" {

    description = "Project name used for tagging resources"
    type = string

}

#----------VPC CIDR----------
variable "aws_vpc_cidr_block" {

    description = "CIDR Block for the AWS VPC"
    type = string

} 

