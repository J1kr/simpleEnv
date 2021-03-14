# Create VPC (CIDR 10.10.0.0/16) 

resource "aws_vpc" "this" {
    cidr_block = var.cidr
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"
    
    tags = merge(var.tags, map("Name", format("%s", var.name)))
}

# Public Subnet
resource "aws_subnet" "public" {
    count             = length(var.public_subnets)
    vpc_id            = aws_vpc.this.id
    cidr_block        = var.public_subnets[count.index]
    availability_zone = var.azs[count.index]

     tags = merge(var.tags, map("Name", format("%s-public-%s", var.name, var.azs[count.index])))
}


# Private Subnet 
resource "aws_subnet" "private" {
    count             = length(var.private_subnets)
    vpc_id            = aws_vpc.this.id
    cidr_block        = var.private_subnets[count.index]
    availability_zone = var.azs[count.index]

     tags = merge(var.tags, map("Name", format("%s-private-%s", var.name, var.azs[count.index])))
}

# private database subnet
resource "aws_subnet" "database" {
  count = length(var.database_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.database_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, map("Name", format("%s-db-%s", var.name, var.azs[count.index])))
}

resource "aws_db_subnet_group" "database" {
  count = length(var.database_subnets) > 0 ? 1 : 0

  name        = var.name
  description = "Database subnet group for ${var.name}"
  subnet_ids  = aws_subnet.database.*.id

  tags = merge(var.tags, map("Name", format("%s", var.name)))
}

resource "aws_eip" "nat" {
  count = length(var.azs)
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "this" {
  count = length(var.azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public[count.index].id

  tags = {
     Name = "${var.name}-nat-gateway"
  }
}

resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, map("Name", format("%s", var.name)))

}

resource "aws_default_network_acl" "dev_default" {
  default_network_acl_id = aws_vpc.this.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  subnet_ids = concat([for subnet in aws_subnet.private: subnet.id], [for subnet in aws_subnet.public: subnet.id], [for subnet in aws_subnet.database: subnet.id])
 

  tags = merge(var.tags, map("Name", format("%s-default", var.name)))
}

resource "aws_default_security_group" "dev_default" {
  vpc_id = aws_vpc.this.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, map("Name", format("%s-default", var.name)))
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, map("Name", format("%s-public", var.name)))
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(var.private_subnets)  
  vpc_id = aws_vpc.this.id

  route {

      cidr_block      = "0.0.0.0/0"
      nat_gateway_id  = aws_nat_gateway.this[count.index].id
  }
  tags = merge(var.tags, map("Name", format("%s-private-%s", var.name, var.azs[count.index])))
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnets)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
