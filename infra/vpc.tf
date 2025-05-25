# VPC configuration for AWS
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public subnet 1 (eu-central-1a)
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"

  tags = {
    Name = "${var.project_name}-public-subnet-1"
    "kubernetes.io/role/elb" = "1"
  }
}

# Public subnet 2 (eu-central-1b)
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr2
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1b"

  tags = {
    Name = "${var.project_name}-public-subnet-2"
    "kubernetes.io/role/elb" = "1"
  }
}

# Private subnet 1 (eu-central-1a)
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "eu-central-1a"

  tags = {
    Name = "${var.project_name}-private-subnet-1"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Private subnet 2 (eu-central-1b)
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr2
  availability_zone = "eu-central-1b"

  tags = {
    Name = "${var.project_name}-private-subnet-2"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Elastic IP for NAT Gateway 1
resource "aws_eip" "nat_1" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-nat-eip-1"
  }
}

# Elastic IP for NAT Gateway 2
resource "aws_eip" "nat_2" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-nat-eip-2"
  }
}

# NAT Gateway 1 (eu-central-1a)
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "${var.project_name}-nat-gw-1"
  }

  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateway 2 (eu-central-1b)
resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name = "${var.project_name}-nat-gw-2"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Private route table 1 (eu-central-1a)
resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }

  tags = {
    Name = "${var.project_name}-private-rt-1"
  }
}

# Private route table 2 (eu-central-1b)
resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  }

  tags = {
    Name = "${var.project_name}-private-rt-2"
  }
}

# Route table associations - Public subnets
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Route table associations - Private subnets
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_2.id
}