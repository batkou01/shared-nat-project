# Create a TGW
resource "aws_ec2_transit_gateway" "tgw_hk" {
    provider                            = aws.hongkong
    default_route_table_association     = "disable"
    default_route_table_propagation     = "disable"
    tags = {
        Name                            = "${var.project_name}-tgw-hk"
    }
}

# Create route table, not the default one.
resource "aws_ec2_transit_gateway_route_table" "tgw_rtb_hk" {
    provider                            = aws.hongkong
    transit_gateway_id                  = aws_ec2_transit_gateway.tgw_hk.id
    tags = {
        Name                            = "${var.project_name}-tgw-rtb-hk"
    } 
}

######### Attachment, association and propagation tgwa VPC A #########

# Create a TGW attachment for VPC C hk
resource "aws_ec2_transit_gateway_vpc_attachment" "tgwa_vpc_c_hk" {
    provider                            = aws.hongkong
    vpc_id                              = aws_vpc.vpc_c.id
    subnet_ids                          = [ aws_subnet.vpc_c_priv_tgw_sub[0].id, aws_subnet.vpc_c_priv_tgw_sub[1].id ]
    transit_gateway_id                  = aws_ec2_transit_gateway.tgw_hk.id
    tags = {
        Name                            = "${var.project_name}-tgw-attachment-vpc-c"
    }   
}

# Associate the TGWA in TGW route table
resource "aws_ec2_transit_gateway_route_table_association" "tgw_rtb_assoc_c" {
    provider                            = aws.hongkong
    transit_gateway_attachment_id       = aws_ec2_transit_gateway_vpc_attachment.tgwa_vpc_c_hk.id 
    transit_gateway_route_table_id      = aws_ec2_transit_gateway_route_table.tgw_rtb_hk.id
}

# Propagate the TGWA in TGW route table
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rtb_prop_c" {
    provider                            = aws.hongkong
    transit_gateway_attachment_id       = aws_ec2_transit_gateway_vpc_attachment.tgwa_vpc_c_hk.id 
    transit_gateway_route_table_id      = aws_ec2_transit_gateway_route_table.tgw_rtb_hk.id
}


######### Association tgwa peering #########

# Associate the TGW peering attachment in TGW HK's route table
resource "aws_ec2_transit_gateway_route_table_association" "tgw_rtb_assoc_peering" {
    provider                            = aws.hongkong
    transit_gateway_attachment_id       = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter.id
    transit_gateway_route_table_id      = aws_ec2_transit_gateway_route_table.tgw_rtb_hk.id
}

######### Add traffic route "0.0.0.0/0" to peering attachment #########

# Add the CIDR block "0.0.0.0/0" in route table with the target of TGW peering attachment
resource "aws_ec2_transit_gateway_route" "tgw_route_peering" {
    provider                            = aws.hongkong
    destination_cidr_block              = "0.0.0.0/0"
    transit_gateway_attachment_id       = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter.id
    transit_gateway_route_table_id      = aws_ec2_transit_gateway_route_table.tgw_rtb_hk.id   
}