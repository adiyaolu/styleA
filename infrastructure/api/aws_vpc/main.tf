#resources
resource "aws_vpc" "this" {

  cidr_block                     = var.vpc_cidr
  enable_dns_support             = var.enable_dns_support
  enable_dns_hostnames           = var.enable_dns_hostnames
  instance_tenancy               = var.instance_tenancy
  enable_classiclink             = var.enable_classiclink
  enable_classiclink_dns_support = var.enable_classiclink_dns_support

  tags = merge(
    {
      "Name" = format("%s-%s-%s", var.project, var.environment, "vpc")
    },
    var.standard_tags
  )
}

resource "aws_vpc_dhcp_options" "this" {
  count = var.create_dhcp_options ? 1 : 0

  domain_name          = var.domain_name
  domain_name_servers  = var.domain_name_servers
  ntp_servers          = var.ntp_servers
  netbios_name_servers = var.netbios_name_servers
  netbios_node_type    = var.netbios_node_type

  tags = merge(
    {
      "Name" = var.project
    },
    var.standard_tags
  )
}

### Gateways
resource "aws_internet_gateway" "this" {
  count = var.create_igw && length(var.public_subnet_cidrs) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-%s-%s", var.project, var.environment, "int_gtw" )
    },
    var.standard_tags
  )
}

resource "aws_eip" "this" {
  count = var.create_nat_gateway ? length(var.availability_zones) : 0
  vpc   = true

  tags = merge(
    {
      "Name" = format("%s-%s-%s", var.project, var.environment, count.index)
    },
    var.standard_tags
  )
}

resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? length(var.private_subnet_cidrs) : 0

  allocation_id = element(aws_eip.this.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(
    {
      "Name" = format("%s-%s-%s", var.project, var.environment, count.index)
    },
    var.standard_tags
  )

}


### Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs) > 0 ? length(var.public_subnet_cidrs) : 0

  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      "Name" = format("%s-%s-%s-%s", var.project, var.environment, "public", count.index)
      Type   = "Public"
    },
    var.standard_tags
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs) > 0 ? length(var.private_subnet_cidrs) : 0

  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(
    {
      "Name" = format("%s-%s-%s-%s", var.project, var.environment, "private", count.index)
      Type   = "Private"
    },
    var.standard_tags
  )
}


### Route Tables
resource "aws_route_table" "public" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-%s-%s-%s", var.project, var.environment, "public", count.index)
    },
    var.standard_tags
  )
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs) > 0 ? length(var.private_subnet_cidrs) : 0
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s-%s-%s-%s", var.project, var.environment, "private", count.index)
    },
    var.standard_tags
  )
}

### Routes
resource "aws_route" "internet_gateway" {
  count = var.create_igw && length(var.public_subnet_cidrs) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_internet_gateway.this.*.id, 0)
}

resource "aws_route" "nat_gateway" {
  count = var.create_nat_gateway ? length(var.private_subnet_cidrs) : 0

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)
}


### Route Table Associations
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}