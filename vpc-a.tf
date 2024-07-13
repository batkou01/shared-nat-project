# Create a VPC A in SG region
resource "aws_vpc" "vpc_a" {
    cidr_block              = var.vpc_a_cidr
    enable_dns_hostnames    = true
    enable_dns_support      = true
    tags = {
        Name                = "${var.project_name}-A-vpc"
    }
}

########## Create public subnet for workloads in VPC A #############

# Create two (2) public subnets
resource "aws_subnet" "vpc_a_pub_sub" {
    count                   = length(var.a_pub_sub_cidr)
    cidr_block              = var.a_pub_sub_cidr[count.index]
    vpc_id                  = aws_vpc.vpc_a.id
    availability_zone       = data.aws_availability_zones.az.names[count.index]
    map_public_ip_on_launch = true
    tags = {
        Name                = "${var.project_name}-A-public-subnet-${count.index + 1}"
    }
}

# Create IGW
resource "aws_internet_gateway" "vpc_a_igw" {
    vpc_id                  = aws_vpc.vpc_a.id
    tags = {
        Name                = "${var.project_name}-A-igw"
    }
}

# Create route table for public subnets
resource "aws_route_table" "a_rtb_pub_subs" {
    vpc_id                  = aws_vpc.vpc_a.id
    route {
        gateway_id          = aws_internet_gateway.vpc_a_igw.id
        cidr_block          = "0.0.0.0/0"  
    }
    tags = {
        Name                = "${var.project_name}-A-pub-subs-rtb"
    }     
}

# Associate public subnets to rtb
resource "aws_route_table_association" "a_pub_rtb_association" {
    count                   = length(var.a_pub_sub_cidr)
    subnet_id               = aws_subnet.vpc_a_pub_sub[count.index].id
    route_table_id          = aws_route_table.a_rtb_pub_subs.id
}

########## Add routes to public subnet route table of VPC A #############

# Add VPC B CIDR block to public route table with the transit gateway as target
resource "aws_route" "a_pub_rtb_route_tgw_vpc_b" {
    route_table_id          = aws_route_table.a_rtb_pub_subs.id
    destination_cidr_block  = var.vpc_b_cidr
    transit_gateway_id      = aws_ec2_transit_gateway.tgw_sg.id
}

# Add VPC C CIDR block to public route table with the transit gateway as target
resource "aws_route" "a_pub_rtb_route_tgw_vpc_c" {
    route_table_id          = aws_route_table.a_rtb_pub_subs.id
    destination_cidr_block  = var.vpc_c_cidr
    transit_gateway_id      = aws_ec2_transit_gateway.tgw_sg.id 
}

########## Create two NAT gateways #############

# Create two (2) EIPs for NAT GW 
resource "aws_eip" "nat_eip" {
    count                   = length(var.a_pub_sub_cidr)
    domain                  = "vpc"
    tags = {
        Name                = "${var.project_name}-nat-eip-${count.index + 1}"
    } 
}

# Create two (2) NAT GW 
resource "aws_nat_gateway" "nat_gw" {
    count                   = length(var.a_pub_sub_cidr)
    subnet_id               = aws_subnet.vpc_a_pub_sub[count.index].id
    allocation_id           = aws_eip.nat_eip[count.index].id
    depends_on              = [ aws_internet_gateway.vpc_a_igw ]
    tags = {
        Name                = "${var.project_name}-nat-gw-${count.index + 1}"
    } 
}

########## Create private subnets for workloads in VPC A #############

# Create two (2) private subnets for workloads
resource "aws_subnet" "vpc_a_priv_workloads_sub" {
    count                   = length(var.a_priv_workloads_sub_cidr)
    cidr_block              = var.a_priv_workloads_sub_cidr[count.index]
    vpc_id                  = aws_vpc.vpc_a.id
    availability_zone       = data.aws_availability_zones.az.names[count.index]
    map_public_ip_on_launch = false
    tags = {
        Name                = "${var.project_name}-A-workloads-private-subnet-${count.index + 1}"
    }
}

# Create private rtb for private subnets workloads
resource "aws_route_table" "a_rtb_priv_subs_workloads" {
    count                   = length(var.a_priv_workloads_sub_cidr)
    vpc_id                  = aws_vpc.vpc_a.id
    route {
        gateway_id          = aws_nat_gateway.nat_gw[count.index].id
        cidr_block          = "0.0.0.0/0"
    }
    tags = {
        Name                = "${var.project_name}-A-priv-subs-workloads-rtb-${count.index + 1}"
    }
}

# Associate private subnets workloads to private rtb
resource "aws_route_table_association" "a_priv_workloads_rtb_association" {
    count                   = length(var.a_priv_workloads_sub_cidr)
    subnet_id               = aws_subnet.vpc_a_priv_workloads_sub[count.index].id
    route_table_id          = aws_route_table.a_rtb_priv_subs_workloads[count.index].id
}

########## Create private subnets for TGW in VPC A #############

# Create two (2) private subnets for TGW
resource "aws_subnet" "vpc_a_priv_tgw_sub" {
    count                   = length(var.a_priv_tgw_sub_cidr)
    cidr_block              = var.a_priv_tgw_sub_cidr[count.index] 
    vpc_id                  = aws_vpc.vpc_a.id
    availability_zone       = data.aws_availability_zones.az.names[count.index]
    map_public_ip_on_launch = false
    tags = {
        Name                = "${var.project_name}-A-tgw-private-subnet-${count.index + 1}"
    }
}

# Create rtb for private subnets tgw
resource "aws_route_table" "a_rtb_priv_subs_tgw" {
    count                   = length(var.a_priv_tgw_sub_cidr)
    vpc_id                  = aws_vpc.vpc_a.id
    route {
        gateway_id          = aws_nat_gateway.nat_gw[count.index].id
        cidr_block          = "0.0.0.0/0"
    }
    tags = {
        Name                = "${var.project_name}-A-priv-subs-tgw-rtb-${count.index + 1}"
    }
}

# Associate private subnets tgw to private rtb
resource "aws_route_table_association" "a_priv_tgw_rtb_association" {
    count                   = length(var.a_priv_tgw_sub_cidr)
    subnet_id               = aws_subnet.vpc_a_priv_tgw_sub[count.index].id
    route_table_id          = aws_route_table.a_rtb_priv_subs_tgw[count.index].id
}

########## Add routes to private subnets route table of VPC A #############

# Add VPC B cidr block in rtb workloads
resource "aws_route" "a_rtb_route_tgw_vpc_b_workload" {
    count                   = length(var.a_priv_workloads_sub_cidr) 
    route_table_id          = aws_route_table.a_rtb_priv_subs_workloads[count.index].id
    destination_cidr_block  = var.vpc_b_cidr
    transit_gateway_id      = aws_ec2_transit_gateway.tgw_sg.id
}

# Add VPC B cidr block in rtb tgw
resource "aws_route" "a_rtb_route_tgw_vpc_b_tgw" {
    count                   = length(var.a_priv_tgw_sub_cidr) 
    route_table_id          = aws_route_table.a_rtb_priv_subs_tgw[count.index].id
    destination_cidr_block  = var.vpc_b_cidr
    transit_gateway_id      = aws_ec2_transit_gateway.tgw_sg.id 
}

# Add VPC C cidr block in rtb workloads
resource "aws_route" "a_rtb_route_tgw_vpc_c_workload" {
    count                   = length(var.a_priv_workloads_sub_cidr) 
    route_table_id          = aws_route_table.a_rtb_priv_subs_workloads[count.index].id
    destination_cidr_block  = var.vpc_c_cidr
    transit_gateway_id      = aws_ec2_transit_gateway.tgw_sg.id 
}

# Add VPC C cidr block in rtb tgw
resource "aws_route" "a_rtb_route_tgw_vpc_c_tgw" {
    count                   = length(var.a_priv_tgw_sub_cidr) 
    route_table_id          = aws_route_table.a_rtb_priv_subs_tgw[count.index].id
    destination_cidr_block  = var.vpc_c_cidr
    transit_gateway_id      = aws_ec2_transit_gateway.tgw_sg.id 
}