resource "aws_vpc" "cnc" {
  cidr_block = "10.118.8.0/22"
  enable_dns_hostnames = true   #assigns a host name to an ec2 instance
  tags = {
      Name = "cyber-range-cnc"
  }
}

#internal Subnets
resource "aws_subnet" "internal-01" {
  vpc_id     = aws_vpc.cnc.id
  cidr_block = "10.118.8.128/25"
  map_public_ip_on_launch = "false"
  availability_zone= "us-east-1a"
  tags = {
    Name = "internal-01"
  }
 
}
resource "aws_subnet" "internal-02" {
  vpc_id     = aws_vpc.cnc.id
  cidr_block = "10.118.9.128/25"
  map_public_ip_on_launch = "false"
  availability_zone = "us-east-1b"
  tags = {
    Name = "internal-02"
  }
 
}

# external subnets
resource "aws_subnet" "external-01" {
  vpc_id     = aws_vpc.cnc.id
  cidr_block = "10.118.8.0/25"
  map_public_ip_on_launch = "true"
  availability_zone= "us-east-1a"
  tags = {
    Name = "external-01"
  }
 
}
resource "aws_subnet" "external-02" {
  vpc_id     = aws_vpc.cnc.id
  cidr_block = "10.118.9.0/25"
  map_public_ip_on_launch = "true"
  availability_zone= "us-east-1b"
  tags = {
    Name = "external-02"
  }
 
}
 
#internet gateway
resource "aws_internet_gateway" "cnc-internet-gw" {
    vpc_id = aws_vpc.cnc.id
 
    tags = {
        Name = "cnc-internet-gw"
    }
}
 
## route table for
 
resource "aws_route_table" "rt-table-public-ig" {
    vpc_id = aws_vpc.cnc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.cnc-internet-gw.id
    }
 
    tags = {
        Name = "rt-cnc-external"
    }
}
 
# route table associtation to public subnets...
resource "aws_route_table_association" "rt-external-association" {
    subnet_id = aws_subnet.external-01.id
    route_table_id = aws_route_table.rt-table-public-ig.id
}
resource "aws_route_table_association" "terraformtraining-public-2-a" {
    subnet_id = aws_subnet.external-02.id
    route_table_id = aws_route_table.rt-table-public-ig.id
}



resource "aws_eip" "nat" {
    vpc = true
}
 
resource "aws_nat_gateway" "cnc-nat-gw" {
allocation_id = aws_eip.nat.id
subnet_id = aws_subnet.external-01.id
depends_on = [aws_internet_gateway.cnc-internet-gw]
tags = {
    Name = "cnc-nat-gw"
  }
}
 
# route table for  NAT Gateway
resource "aws_route_table" "rt-cnc-internal" {
    vpc_id = aws_vpc.cnc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.cnc-nat-gw.id
    }
 
    tags = {
        Name = "cnc-nat-gw-route-table"
    }
}
 

# NAT Gateway route table association for internal subnet.
resource "aws_route_table_association" "cnc-internal-01-rt-association" {
    subnet_id = aws_subnet.internal-01.id
    route_table_id = aws_route_table.rt-cnc-internal.id
}
resource "aws_route_table_association" "cnc-internal-02-rt-association" {
    subnet_id = aws_subnet.internal-02.id
    route_table_id = aws_route_table.rt-cnc-internal.id
}