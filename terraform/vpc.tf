// Set up your vpc
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${local.project_name}_main"
  }
}

// Enables instances in VPC to connect to the internet
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${local.project_name}_internet_gateway"
  }
}

// Public route tables have associations to the internet gateway
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.internet-gateway.id
  }

  tags = {
    Name = "${local.project_name}_public_route_table"
  }
}

// Create your subnets (AWS requires minimum 2 availability zones)
resource "aws_subnet" "public_subnets" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${local.project_name}-public-${each.value.availability_zone}"
  }
}

//  Route table associations
//  All public subnets have associations with the public route table
resource "aws_route_table_association" "public_route_table_associations" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public_route_table.id
}

// Define a security group for the vpc (used by your ec2 instances)
resource "aws_security_group" "vpc_security_group" {
  name   = "${local.project_name}-vpc-sg"
  vpc_id = aws_vpc.main_vpc.id

  // Inbound HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow Inbound SSH for debugging purposes
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}