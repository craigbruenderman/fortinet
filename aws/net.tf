data "aws_region" "current" {}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "172.30.0.0/16"

  tags = {
    Name = "e1-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "e1-igw"
  }
}

resource "aws_ec2_transit_gateway" "tgw" {
  description = "e1-tgw"

  tags = {
    Name = "e1-tgw"
  }
}

resource "aws_subnet" "snet-priv1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.30.1.0/24"

  tags = {
    Name = "e1-snet-priv1"
  }
}

resource "aws_subnet" "snet-priv2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.30.2.0/24"

  tags = {
    Name = "e1-snet-priv2"
  }
}

resource "aws_route_table" "rt-priv" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "e1-rt-priv"
  }
}

resource "aws_route" "internalroute" {
  depends_on             = [aws_instance.fgtvm]
  route_table_id         = aws_route_table.rt-priv.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.eth1.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.snet-priv1.id
  route_table_id = aws_route_table.rt-priv.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.snet-priv2.id
  route_table_id = aws_route_table.rt-priv.id
}

resource "aws_subnet" "snet-pub1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.30.100.0/24"

  tags = {
    Name = "e1-snet-pub1"
  }
}

resource "aws_subnet" "snet-pub2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.30.200.0/24"

  tags = {
    Name = "e1-snet-pub2"
  }
}

resource "aws_route_table" "rt-pub" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "e1-rt-pub"
  }
}

resource "aws_route" "externalroute" {
  route_table_id         = aws_route_table.rt-pub.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.snet-pub1.id
  route_table_id = aws_route_table.rt-pub.id
}

resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.snet-pub2.id
  route_table_id = aws_route_table.rt-pub.id
}

resource "aws_eip" "FGTPublicIP" {
  depends_on        = [aws_instance.fgtvm]
  domain            = "vpc"
  network_interface = aws_network_interface.eth0.id
}

resource "aws_eip" "eip-bastion" {
  depends_on        = [aws_instance.bastion]
  domain            = "vpc"
  network_interface = aws_network_interface.eni-bastion.id
}

resource "aws_security_group" "public_allow" {
  name        = "Allow Management"
  description = "Allow management traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow Management"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "Allow All"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow All"
  }
}