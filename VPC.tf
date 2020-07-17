provider "aws" {
  region                  = "ap-south-1"
  shared_credentials_file = "C:/Users/KIIT/.aws/credentials"
  profile                 = "chirag"
}

resource "tls_private_key" "keypair" {
  algorithm   = "RSA"
}

resource "local_file" "privatekey" {
    content     = tls_private_key.keypair.private_key_pem
    filename = "key1.pem"
}

resource "aws_key_pair" "deployer" {
  key_name   = "key1.pem"
  public_key = tls_private_key.keypair.public_key_openssh
}

resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}

resource "aws_route_table" "routetable1" {
  vpc_id    = aws_vpc.main.id
}

resource "aws_route" "route1" {
  route_table_id         = aws_route_table.routetable1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.intgw.id
}

resource "aws_route_table_association" "routetableassoc1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.routetable1.id
}

resource "aws_route_table" "routetable2" {
  vpc_id    = aws_vpc.main.id
}

resource "aws_route" "route2" {
  route_table_id         = aws_route_table.routetable2.id
  destination_cidr_block = "0.0.0.0/0"
  instance_id= aws_instance.wordpress.id
}

resource "aws_route_table_association" "routetableassoc2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.routetable2.id
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-south-1a"
  cidr_block        = "192.168.1.0/24"
  map_public_ip_on_launch="true"
  tags              = map("Name","Subnet1")
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-south-1a"
  cidr_block        = "192.168.2.0/24"
  map_public_ip_on_launch="false"
  tags              = map("Name","Subnet2")
}

resource "aws_internet_gateway" "intgw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  instance                  = aws_instance.mysql.id
  depends_on                = [aws_internet_gateway.intgw]
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet2.id

  depends_on = [aws_internet_gateway.intgw]

  tags = {
    Name = "gw NAT"
  }
}