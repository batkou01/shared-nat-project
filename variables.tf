variable "project_name" {
    default = "natgw-project"
}

# VPC A cidr block
variable "vpc_a_cidr" {
    default = "10.1.0.0/16"
}

# Public subnets cidr block
variable "a_pub_sub_cidr" {
    type = list(string)
    default = [ "10.1.1.0/24", "10.1.2.0/24" ]
}

# Private subnets for workloads cidr block
variable "a_priv_workloads_sub_cidr" {
    type = list(string)
    default = [ "10.1.11.0/24", "10.1.12.0/24" ]
}

# Private subnets for TGW cidr block
variable "a_priv_tgw_sub_cidr" {
    type = list(string)
    default = [ "10.1.101.0/28", "10.1.102.0/28" ]
}

##### VPC B #####

# VPC B cidr block
variable "vpc_b_cidr" {
    default = "10.2.0.0/16"
}

# Public subnets cidr block
variable "b_pub_sub_cidr" {
    type = list(string)
    default = [ "10.2.1.0/24", "10.2.2.0/24" ]
}

# Private subnets for workloads cidr block
variable "b_priv_workloads_sub_cidr" {
    type = list(string)
    default = [ "10.2.11.0/24", "10.2.12.0/24" ]
}

# Private subnets for TGW cidr block
variable "b_priv_tgw_sub_cidr" {
    type = list(string)
    default = [ "10.2.101.0/28", "10.2.102.0/28" ]
}

##### VPC C #####

# VPC C cidr block
variable "vpc_c_cidr" {
    default = "10.3.0.0/16"
}

# Public subnets cidr block
variable "c_pub_sub_cidr" {
    type = list(string)
    default = [ "10.3.1.0/24", "10.3.2.0/24" ]
}

# Private subnets for workloads cidr block
variable "c_priv_workloads_sub_cidr" {
    type = list(string)
    default = [ "10.3.11.0/24", "10.3.12.0/24" ]
}

# Private subnets for TGW cidr block
variable "c_priv_tgw_sub_cidr" {
    type = list(string)
    default = [ "10.3.101.0/28", "10.3.102.0/28" ]
}

data "aws_availability_zones" "az" {}

data "aws_availability_zones" "azhk" {
    provider = aws.hongkong  
}