# Create a TGW
resource "aws_ec2_transit_gateway" "tgw_sg" {
    default_route_table_association     = "disable"
    default_route_table_propagation     = "disable"
    tags = {
        Name                            = "${var.project_name}-tgw"
    }
}

# Create route table, not the default one.
resource "aws_ec2_transit_gateway_route_table" "tgw_rtb_sg" {
    transit_gateway_id                  = aws_ec2_transit_gateway.tgw_sg.id
    tags = {
        Name                            = "${var.project_name}-tgw-rtb-sg"
    } 
}

######### Attachment, association and propagation tgwa VPC A #########

# Create a TGW attachment for VPC A
resource "aws_ec2_transit_gateway_vpc_attachment" "tgwa_vpc_a" {
    vpc_id                              = aws_vpc.vpc_a.id
    subnet_ids                          = [ aws_subnet.vpc_a_priv_tgw_sub[0].id, aws_subnet.vpc_a_priv_tgw_sub[1].id ]
    transit_gateway_id                  = aws_ec2_transit_gateway.tgw_sg.id
    tags = {
        Name                            = "${var.project_name}-tgw-attachment-vpc-a"
    }   
}

# Associate the TGWA in TGW route table
resource "aws_ec2_transit_gateway_route_table_association" "tgw_rtb_assoc_a" {
    transit_gateway_attachment_id       = aws_ec2_transit_gateway_vpc_attachment.tgwa_vpc_a.id 
    transit_gateway_route_table_id      = aws_ec2_transit_gateway_route_table.tgw_rtb_sg.id
}

# Propagate the TGWA in TGW route table
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rtb_prop_a" {
    transit_gateway_attachment_id       = aws_ec2_transit_gateway_vpc_attachment.tgwa_vpc_a.id 
    transit_gateway_route_table_id      = aws_ec2_transit_gateway_route_table.tgw_rtb_sg.id
}

######### Attachment, association and propagation tgwa VPC B #########

# Create a TGW attachment for VPC B
resource "aws_ec2_transit_gateway_vpc_attachment" "tgwa_vpc_b" {
    vpc_id                              = aws_vpc.vpc_b.id
    subnet_ids                          = [ aws_subnet.vpc_b_priv_tgw_sub[0].id, aws_subnet.vpc_b_priv_tgw_sub[1].id ]
    transit_gateway_id                  = aws_ec2_transit_gateway.tgw_sg.id
    tags = {
        Name                            = "${var.project_name}-tgw-attachment-vpc-b"
    }   
}

# Associate the TGWA in TGW route table
resource "aws_ec2_transit_gateway_route_table_association" "tgw_rtb_assoc_b" {
    transit_gateway_attachment_id       = aws_ec2_transit_gateway_vpc_attachment.tgwa_vpc_b.id 
    transit_gateway_route_table_id      = aws_ec2_transit_gateway_route_table.tgw_rtb_sg.id
}

# Propagate the TGWA in TGW route table
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rtb_prop_b" {
    transit_gateway_attachment_id       = aws_ec2_transit_gateway_vpc_attachment.tgwa_vpc_b.id 
    transit_gateway_route_table_id      = aws_ec2_transit_gateway_route_table.tgw_rtb_sg.id
}

######### Add a CIDR block "0.0.0.0/0" in route table of TGW with the target of VPC A attachment #########
 
# Add "0.0.0.0/0" CIDR block for VPC A traffic in tgw route table
resource "aws_ec2_transit_gateway_route" "tgw_route_vpc_a" {
    destination_cidr_block              = "0.0.0.0/0"
    transit_gateway_attachment_id       = aws_ec2_transit_gateway_vpc_attachment.tgwa_vpc_a.id
    transit_gateway_route_table_id      = aws_ec2_transit_gateway_route_table.tgw_rtb_sg.id   
}

######### Association tgwa peering #########

# Associate the TGW peering attachment in TGW SG's route table
resource "aws_ec2_transit_gateway_route_table_association" "tgw_sg_rtb_assoc_peering" {
    transit_gateway_attachment_id       = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter.id
    transit_gateway_route_table_id      = aws_ec2_transit_gateway_route_table.tgw_rtb_sg.id
}

# Add the CIDR block of VPC C in route table with the target of TGW peering attachment
resource "aws_ec2_transit_gateway_route" "tgw_sg_route_peering" {
    destination_cidr_block              = var.vpc_c_cidr
    transit_gateway_attachment_id       = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter.id
    transit_gateway_route_table_id      = aws_ec2_transit_gateway_route_table.tgw_rtb_sg.id 
}

