resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge({
    Name = var.vpc_name
  }, var.default_tags)
}


resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id
  tags = merge({
    Name = "${var.vpc_name}-private"
  }, var.default_tags)
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  tags = merge({
    Name = "${var.vpc_name}-public",
  }, var.default_tags)
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge({
    Name = "${var.vpc_name}-IGW"
  }, var.default_tags)
}


resource "aws_route" "public-route" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


resource "aws_eip" "eip" {
  count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags = merge({
    Name = "${var.vpc_name}-eip-${count.index + 1}"
  }, var.default_tags)
}


resource "aws_nat_gateway" "nat" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.eip.*.id, count.index)
  tags = merge({
    Name = "${var.vpc_name}-NatGateway-${count.index + 1}"
    },
  var.default_tags)
}


resource "aws_route_table" "private-route-table" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }
  tags = merge({
    Name = "${var.vpc_name}-PrivateRouteTable-${count.index + 1}"
    },
  var.default_tags)
}


resource "aws_route_table_association" "route-association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private-route-table.*.id, count.index)
}
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.vpc_name}_db_sgrp"
  description = "The Database Subnet Group"
  subnet_ids  = data.aws_subnet_ids.private.ids
  tags        = var.default_tags
}

#==========================================================
# Output
#==========================================================
output "vpc_eip" {
  value = resource.aws_eip.eip
}
output "vpc_id" {
  value = resource.aws_vpc.main.id
}

output "rds_subnet_group_id" {
  value = aws_db_subnet_group.db_subnet_group.id
}

output "private_subnet_ids" {
  value = data.aws_subnet_ids.private.ids
}

output "public_subnet_ids" {
  value = data.aws_subnet_ids.public.ids
}
