# Create peering connection from TGW SG to TGW HK
resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering" {
    # peer_account_id               = <AWS ACCOUNT ID> Peering to another AWS account
    peer_region                     = "ap-east-1" 
    peer_transit_gateway_id         = aws_ec2_transit_gateway.tgw_hk.id
    transit_gateway_id              = aws_ec2_transit_gateway.tgw_sg.id
    tags = {
        Name                        = "TGW Peering Requestor"
  }  
}

# Retrieve peering data for acceptance
data "aws_ec2_transit_gateway_peering_attachment" "tgw_peering_get_data" {
    provider                        = aws.hongkong
    filter {
        name                        = "state"
        values                      = [ "pendingAcceptance" , "available" ]
    }
    filter {
        name                        = "transit-gateway-id"
        values                      = [ aws_ec2_transit_gateway.tgw_hk.id ] 
    }
    depends_on = [ aws_ec2_transit_gateway_peering_attachment.tgw_peering ]
}

# Accept the peering connection in TGW HK
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter" {
    provider                        = aws.hongkong
    transit_gateway_attachment_id   = data.aws_ec2_transit_gateway_peering_attachment.tgw_peering_get_data.id 
    tags = {
        Name = "TGW-acceptor"
  }
}