data "aws_availability_zones" "available" {}
data "aws_vpc" "vpc" {
  id = resource.aws_vpc.main.id
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-private"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-public"
  }
}


