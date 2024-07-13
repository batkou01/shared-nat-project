# Create ec2 instance in VPC B
resource "aws_instance" "instance_vpc_b" {
    instance_type                   = "t3.small"
    ami                             = "ami-060e277c0d4cce553"
    vpc_security_group_ids          = [ aws_security_group.sg_instance_b.id ]
    subnet_id                       = aws_subnet.vpc_b_priv_workloads_sub[0].id
    iam_instance_profile            = "AmazonSSMRoleForInstancesQuickSetup"
    root_block_device {
        volume_type                 = "gp3"
        volume_size                 = 10
    }
    tags = {
        Name                        = "${var.project_name}-ec2-vpc-b"
    }
}

# Security group for instance in VPC B
resource "aws_security_group" "sg_instance_b" {
    vpc_id                          = aws_vpc.vpc_b.id
    name                            = "${var.project_name}-vpc-b-sg"
    tags = {
      Name                          = "${var.project_name}-vpc-b-sg"
    }
    egress {
            cidr_blocks             = [ "0.0.0.0/0"]
            to_port                 = 0
            from_port               = 0
            protocol                = -1
    }
}

# Create ec2 instance in VPC C
resource "aws_instance" "instance_vpc_c" {
    provider                        = aws.hongkong 
    instance_type                   = "t3.small"
    ami                             = "ami-09b252924449d82f9"
    vpc_security_group_ids          = [ aws_security_group.sg_instance_c.id ]
    subnet_id                       = aws_subnet.vpc_c_priv_workloads_sub[0].id
    iam_instance_profile            = "AmazonSSMRoleForInstancesQuickSetup"
    root_block_device {
        volume_type                 = "gp3"
        volume_size                 = 10
    }
    tags = {
        Name                        = "${var.project_name}-ec2-vpc-c"
    }
}

# Security group for instance in VPC C
resource "aws_security_group" "sg_instance_c" {
    provider                        = aws.hongkong
    vpc_id                          = aws_vpc.vpc_c.id
    name                            = "${var.project_name}-vpc-c-sg"
    tags = {
      Name                          = "${var.project_name}-vpc-c-sg"
    }
    egress {
            cidr_blocks             = [ "0.0.0.0/0"]
            to_port                 = 0
            from_port               = 0
            protocol                = -1
    }
}