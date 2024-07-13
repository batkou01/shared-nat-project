# Create a VPC C in HK region
resource "aws_vpc" "vpc_c" {
    provider                = aws.hongkong
    cidr_block              = var.vpc_c_cidr
    enable_dns_hostnames    = true
    enable_dns_support      = true
    tags = {
        Name                = "${var.project_name}-C-vpc"
    }
}

########## Create public subnet for workloads in VPC C #############

# Create two (2) public subnets
resource "aws_subnet" "vpc_c_pub_sub" {
    provider                = aws.hongkong
    count                   = length(var.c_pub_sub_cidr)
    cidr_block              = var.c_pub_sub_cidr[count.index]
    vpc_id                  = aws_vpc.vpc_c.id
    availability_zone       = data.aws_availability_zones.azhk.names[count.index]
    map_public_ip_on_launch = true
    tags = {
        Name                = "${var.project_name}-C-public-subnet-${count.index + 1}"
    }
}

# Create IGW
resource "aws_internet_gateway" "vpc_c_igw" {
    provider                = aws.hongkong
    vpc_id                  = aws_vpc.vpc_c.id
    tags = {
        Name                = "${var.project_name}-C-igw"
    }
}

# Create route table for public subnets
resource "aws_route_table" "c_rtb_pub_subs" {
    provider                = aws.hongkong
    vpc_id                  = aws_vpc.vpc_c.id
    route {
        gateway_id          = aws_internet_gateway.vpc_c_igw.id
        cidr_block          = "0.0.0.0/0"  
    }
    tags = {
        Name                = "${var.project_name}-C-pub-subs-rtb"
    }     
}

# Associate public subnets to rtb
resource "aws_route_table_association" "c_rtb_association" {
    provider                = aws.hongkong
    count                   = length(var.c_pub_sub_cidr)
    subnet_id               = aws_subnet.vpc_c_pub_sub[count.index].id
    route_table_id          = aws_route_table.c_rtb_pub_subs.id
}

########## Create private subnets for workloads in VPC C #############


# Create two (2) private subnets for workloads
resource "aws_subnet" "vpc_c_priv_workloads_sub" {
    provider                = aws.hongkong
    count                   = length(var.c_priv_workloads_sub_cidr)
    cidr_block              = var.c_priv_workloads_sub_cidr[count.index]
    vpc_id                  = aws_vpc.vpc_c.id
    availability_zone       = data.aws_availability_zones.azhk.names[count.index]
    map_public_ip_on_launch = false
    tags = {
        Name                = "${var.project_name}-C-workloads-private-subnet-${count.index + 1}"
    }
}

# Create rtb for private subnets workloads
resource "aws_route_table" "c_rtb_priv_subs_workloads" {
    provider                = aws.hongkong
    count                   = length(var.c_priv_workloads_sub_cidr)
    vpc_id                  = aws_vpc.vpc_c.id
    tags = {
        Name                = "${var.project_name}-C-priv-subs-workloads-rtb-${count.index + 1}"
    }
}

# Associate private subnets workloads to rtb
resource "aws_route_table_association" "c_priv_workloads_rtb_association" {
    provider                = aws.hongkong
    count                   = length(var.c_priv_workloads_sub_cidr)
    subnet_id               = aws_subnet.vpc_c_priv_workloads_sub[count.index].id
    route_table_id          = aws_route_table.c_rtb_priv_subs_workloads[count.index].id
}

########## Create private subnets for TGW in VPC C #############


# Create two (2) private subnets for TGW
resource "aws_subnet" "vpc_c_priv_tgw_sub" {
    provider                = aws.hongkong
    count                   = length(var.c_priv_tgw_sub_cidr)
    cidr_block              = var.c_priv_tgw_sub_cidr[count.index]
    vpc_id                  = aws_vpc.vpc_c.id
    availability_zone       = data.aws_availability_zones.azhk.names[count.index]
    map_public_ip_on_launch = false
    tags = {
        Name                = "${var.project_name}-C-tgw-private-subnet-${count.index + 1}"
    }
}

# Create rtb for private subnets tgw
resource "aws_route_table" "c_rtb_priv_subs_tgw" {
    provider                = aws.hongkong
    count                   = length(var.c_priv_tgw_sub_cidr)
    vpc_id                  = aws_vpc.vpc_c.id
    tags = {
        Name                = "${var.project_name}-C-priv-subs-tgw-rtb-${count.index + 1}"
    }
}

# Associate private subnets tgw to rtb
resource "aws_route_table_association" "c_priv_tgw_rtb_association" {
    provider                = aws.hongkong
    count                   = length(var.c_priv_tgw_sub_cidr)
    subnet_id               = aws_subnet.vpc_c_priv_tgw_sub[count.index].id
    route_table_id          = aws_route_table.c_rtb_priv_subs_tgw[count.index].id
}

########## Add CIDR block "0.0.0.0/0" route to private route tables of workload and TGW subnets #############

# Add "0.0.0.0/0" in rtb workloads
resource "aws_route" "c_rtb_route_tgw_vpc_c_workload" {
    provider                = aws.hongkong
    count                   = length(var.c_priv_workloads_sub_cidr) 
    route_table_id          = aws_route_table.c_rtb_priv_subs_workloads[count.index].id
    destination_cidr_block  = "0.0.0.0/0"
    transit_gateway_id      = aws_ec2_transit_gateway.tgw_hk.id
}

# Add "0.0.0.0/0" in rtb TGW
resource "aws_route" "c_rtb_route_tgw_vpc_c_tgw" {
    provider                = aws.hongkong
    count                   = length(var.c_priv_tgw_sub_cidr) 
    route_table_id          = aws_route_table.c_rtb_priv_subs_tgw[count.index].id
    destination_cidr_block  = "0.0.0.0/0"
    transit_gateway_id      = aws_ec2_transit_gateway.tgw_hk.id 
}