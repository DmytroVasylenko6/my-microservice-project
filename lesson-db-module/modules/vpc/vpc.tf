resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = var.vpc_name
  })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-igw"
  })
}

# Public subnets
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnets : idx => cidr }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, tonumber(each.key))
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-public-${each.key}"
    Tier = "public"
  })
}

# Elastic IPs for NAT Gateways (one per public subnet)
resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  vpc      = true
  tags = merge(var.tags, {
    Name = "${var.vpc_name}-nat-eip-${each.key}"
  })
}

# NAT Gateways in public subnets (one per public subnet)
resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-nat-${each.key}"
  })
}

# Private subnets
resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnets : idx => cidr }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, tonumber(each.key))
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-private-${each.key}"
    Tier = "private"
  })
}

