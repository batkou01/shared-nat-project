# Create a VPC B in SG region
resource "aws_vpc" "vpc_b" {
    cidr_block              = var.vpc_b_cidr
    enable_dns_hostnames    = true
    enable_dns_support      = true
    tags = {
        Name                = "${var.project_name}-B-vpc"
    }
}

########## Create public subnet for workloads in VPC B #############

# Create two (2) public subnets
resource "aws_subnet" "vpc_b_pub_sub" {
    count                   = length(var.b_pub_sub_cidr)
    cidr_block              = var.b_pub_sub_cidr[count.index]
    vpc_id                  = aws_vpc.vpc_b.id
    availability_zone       = data.aws_availability_zones.az.names[count.index]
    map_public_ip_on_launch = true
    tags = {
        Name                = "${var.project_name}-B-public-subnet-${count.index + 1}"
    }
}

# Create IGW
resource "aws_internet_gateway" "vpc_b_igw" {
    vpc_id                  = aws_vpc.vpc_b.id
    tags = {
        Name                = "${var.project_name}-B-igw"
    }
}

# Create route table for public subnets
resource "aws_route_table" "b_rtb_pub_subs" {
    vpc_id                  = aws_vpc.vpc_b.id
    route {
        gateway_id          = aws_internet_gateway.vpc_b_igw.id
        cidr_block          = "0.0.0.0/0"  
    }
    tags = {
        Name                = "${var.project_name}-A-pub-subs-rtb"
    }     
}

# Associate public subnets to rtb
resource "aws_route_table_association" "b_rtb_association" {
    count = length(var.b_pub_sub_cidr)
    subnet_id = aws_subnet.vpc_b_pub_sub[count.index].id
    route_table_id = aws_route_table.b_rtb_pub_subs.id
}

########## Create private subnets for workloads in VPC B #############

# Create two (2) private subnets for workloads
resource "aws_subnet" "vpc_b_priv_workloads_sub" {
    count                   = length(var.b_priv_workloads_sub_cidr)
    cidr_block              = var.b_priv_workloads_sub_cidr[count.index]
    vpc_id                  = aws_vpc.vpc_b.id
    availability_zone       = data.aws_availability_zones.az.names[count.index]
    map_public_ip_on_launch = false
    tags = {
        Name                = "${var.project_name}-B-workloads-private-subnet-${count.index + 1}"
    }
}

# Create rtb for private subnets workloads
resource "aws_route_table" "b_rtb_priv_subs_workloads" {
    count                   = length(var.b_priv_workloads_sub_cidr)
    vpc_id                  = aws_vpc.vpc_b.id
    tags = {
        Name                = "${var.project_name}-B-priv-subs-workloads-rtb-${count.index + 1}"
    }
}

# Associate private subnets workloads to rtb
resource "aws_route_table_association" "b_priv_workloads_rtb_association" {
    count                   = length(var.b_priv_workloads_sub_cidr)
    subnet_id               = aws_subnet.vpc_b_priv_workloads_sub[count.index].id
    route_table_id          = aws_route_table.b_rtb_priv_subs_workloads[count.index].id
}

########## Create private subnets for TGW in VPC B #############

# Create two (2) private subnets for TGW
resource "aws_subnet" "vpc_b_priv_tgw_sub" {
    count                   = length(var.b_priv_tgw_sub_cidr)
    cidr_block              = var.b_priv_tgw_sub_cidr[count.index]
    vpc_id                  = aws_vpc.vpc_b.id
    availability_zone       = data.aws_availability_zones.az.names[count.index]
    map_public_ip_on_launch = false
    tags = {
        Name                = "${var.project_name}-B-tgw-private-subnet-${count.index + 1}"
    }
}

# Create rtb for private subnets tgw
resource "aws_route_table" "b_rtb_priv_subs_tgw" {
    count                   = length(var.b_priv_tgw_sub_cidr)
    vpc_id                  = aws_vpc.vpc_b.id
    tags = {
        Name                = "${var.project_name}-B-priv-subs-tgw-rtb-${count.index + 1}"
    }
}

# Associate private subnets tgw to rtb
resource "aws_route_table_association" "b_priv_tgw_rtb_association" {
    count                   = length(var.b_priv_tgw_sub_cidr)
    subnet_id               = aws_subnet.vpc_b_priv_tgw_sub[count.index].id
    route_table_id          = aws_route_table.b_rtb_priv_subs_tgw[count.index].id
}

########## Add CIDR block "0.0.0.0/0" route to private route tables of workload and TGW subnets #############

# Add "0.0.0.0/0" in rtb workloads
resource "aws_route" "b_rtb_route_tgw_vpc_a_workload" {
    count                   = length(var.b_priv_workloads_sub_cidr) 
    route_table_id          = aws_route_table.b_rtb_priv_subs_workloads[count.index].id
    destination_cidr_block  = "0.0.0.0/0"
    transit_gateway_id      = aws_ec2_transit_gateway.tgw_sg.id
}

# Add "0.0.0.0/0" in rtb TGW
resource "aws_route" "b_rtb_route_tgw_vpc_a_tgw" {
    count                   = length(var.b_priv_tgw_sub_cidr) 
    route_table_id          = aws_route_table.b_rtb_priv_subs_tgw[count.index].id
    destination_cidr_block  = "0.0.0.0/0"
    transit_gateway_id      = aws_ec2_transit_gateway.tgw_sg.id 
}