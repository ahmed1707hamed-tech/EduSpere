#############################
# VPC
#############################

resource "aws_vpc" "this" {

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }

}

#############################
# Internet Gateway
#############################

resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-igw"
  }

}

#############################
# Public Subnet A
#############################

resource "aws_subnet" "public_1" {

  vpc_id = aws_vpc.this.id

  cidr_block = var.public_subnet_1_cidr

  availability_zone = "${var.region}a"

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-1"
  }

}

#############################
# Public Subnet B
#############################

resource "aws_subnet" "public_2" {

  vpc_id = aws_vpc.this.id

  cidr_block = var.public_subnet_2_cidr

  availability_zone = "${var.region}b"

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-2"
  }

}

#############################
# Private App Subnet A
#############################

resource "aws_subnet" "private_app_1" {

  vpc_id = aws_vpc.this.id

  cidr_block = var.private_app_subnet_1_cidr

  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.project_name}-private-app-1"
  }

}

#############################
# Private App Subnet B
#############################

resource "aws_subnet" "private_app_2" {

  vpc_id = aws_vpc.this.id

  cidr_block = var.private_app_subnet_2_cidr

  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.project_name}-private-app-2"
  }

}

#############################
# Private DB Subnet A
#############################

resource "aws_subnet" "private_db_1" {

  vpc_id = aws_vpc.this.id

  cidr_block = var.private_db_subnet_1_cidr

  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.project_name}-private-db-1"
  }

}

#############################
# Private DB Subnet B
#############################

resource "aws_subnet" "private_db_2" {

  vpc_id = aws_vpc.this.id

  cidr_block = var.private_db_subnet_2_cidr

  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.project_name}-private-db-2"
  }

}

#############################
# Elastic IP for NAT Gateway
#############################

resource "aws_eip" "nat" {

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }

}
#############################
# NAT Gateway
#############################

resource "aws_nat_gateway" "this" {

  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public_1.id

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {
    Name = "${var.project_name}-nat"
  }

}
#############################
# Public Route Table
#############################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.this.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.this.id

  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }

}
resource "aws_route_table_association" "public_1" {

  subnet_id = aws_subnet.public_1.id

  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "public_2" {

  subnet_id = aws_subnet.public_2.id

  route_table_id = aws_route_table.public.id

}
#############################
# Private App Route Table
#############################

resource "aws_route_table" "private_app" {

  vpc_id = aws_vpc.this.id

  route {

    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.this.id

  }

  tags = {
    Name = "${var.project_name}-private-app-rt"
  }

}
resource "aws_route_table_association" "private_app_1" {

  subnet_id = aws_subnet.private_app_1.id

  route_table_id = aws_route_table.private_app.id

}

resource "aws_route_table_association" "private_app_2" {

  subnet_id = aws_subnet.private_app_2.id

  route_table_id = aws_route_table.private_app.id

}
#############################
# Private DB Route Table
#############################

resource "aws_route_table" "private_db" {

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-private-db-rt"
  }

}
resource "aws_route_table_association" "private_db_1" {

  subnet_id = aws_subnet.private_db_1.id

  route_table_id = aws_route_table.private_db.id

}

resource "aws_route_table_association" "private_db_2" {

  subnet_id = aws_subnet.private_db_2.id

  route_table_id = aws_route_table.private_db.id

}