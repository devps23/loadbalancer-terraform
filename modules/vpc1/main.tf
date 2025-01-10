resource "aws_vpc" "dev" {
  cidr_block = "10.10.0.0/24"

  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "${var.env}-vpc-igw"
  }
}

resource "aws_vpc_peering_connection" "foo" {
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.dev.id
  auto_accept   = true

  tags = {
    Name = "dev-vpc to default-vpc"
  }
}

resource "aws_route" "dev-route" {
  route_table_id             = aws_vpc.dev.default_route_table_id
  vpc_peering_connection_id  = aws_vpc_peering_connection.foo.id
  destination_cidr_block     =  "172.31.0.0/16"
}

resource "aws_route" "default-vpc-route" {
  route_table_id             = "rtb-0a2e9ff93585c96fd"
  vpc_peering_connection_id  = aws_vpc_peering_connection.foo.id
  destination_cidr_block     =  aws_vpc.dev.cidr_block
}
resource "aws_subnet" "public-subnets" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.dev.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "${var.env}-public${count.index+1}-${var.availability_zone[count.index]}-${var.public_subnets[count.index]}"
  }
}
resource "aws_route_table" "public-rt" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    cidr_block = "172.31.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
  }


  tags = {
    Name = "${var.env}-public-rt${count.index+1}-${var.availability_zone[count.index]}-${var.public_subnets[count.index]}"
  }
}

resource "aws_route_table_association" "public-rt-a" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.public-rt[count.index].id
}


resource "aws_eip" "eips" {
  count    = length(var.public_subnets)
  domain   = "vpc"
}


resource "aws_nat_gateway" "nat-igw" {
  count        = length(var.public_subnets)
  allocation_id = aws_eip.eips[count.index].id
  subnet_id     = aws_subnet.public-subnets[count.index].id

  tags = {
    Name = "${var.env}-nat-igw${count.index+1}-${var.availability_zone[count.index]}-${var.public_subnets[count.index]}"
  }
}



resource "aws_subnet" "frontend" {
  count = length(var.frontend_subnets)

  vpc_id = aws_vpc.dev.id
  cidr_block = var.frontend_subnets[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "${var.env}-frontend${count.index+1}-${var.availability_zone[count.index]}-${var.frontend_subnets[count.index]}"
  }
}

resource "aws_route_table" "frontend-rt" {
  count = length(var.frontend_subnets)
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "172.31.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-igw[count.index].id
  }


  tags = {
    Name = "${var.env}-frontend-rt${count.index+1}-${var.availability_zone[count.index]}-${var.frontend_subnets[count.index]}"
  }
}

resource "aws_route_table_association" "frontend-rt-a" {
  count          = length(var.frontend_subnets)
  subnet_id      = aws_subnet.frontend[count.index].id
  route_table_id = aws_route_table.frontend-rt[count.index].id
}




#
# resource "aws_subnet" "backend" {
#   count = length(var.backend_subnets)
#
#   vpc_id = aws_vpc.dev.id
#   cidr_block = var.backend_subnets[count.index]
#   availability_zone = var.availability_zone[count.index]
#
#   tags = {
#     Name = "${var.env}-backend${count.index+1}-${var.availability_zone[count.index]}-${var.backend_subnets[count.index]}"
#   }
# }
#
# resource "aws_route_table" "backend-rt" {
#   count = length(var.backend_subnets)
#   vpc_id = aws_vpc.dev.id
#
#   route {
#     cidr_block = "172.31.0.0/16"
#     vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
#   }
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat-igw[count.index].id
#   }
#
#
#   tags = {
#     Name = "${var.env}-backend-rt${count.index+1}-${var.availability_zone[count.index]}-${var.backend_subnets[count.index]}"
#   }
# }
#
#
# resource "aws_route_table_association" "backend-rt-a" {
#   count          = length(var.backend_subnets)
#   subnet_id      = aws_subnet.backend[count.index].id
#   route_table_id = aws_route_table.backend-rt[count.index].id
# }



#
# resource "aws_subnet" "mysql" {
#   count = length(var.mysql_subnets)
#
#   vpc_id = aws_vpc.dev.id
#   cidr_block = var.mysql_subnets[count.index]
#   availability_zone = var.availability_zone[count.index]
#
#   tags = {
#     Name = "${var.env}-mysql${count.index+1}-${var.availability_zone[count.index]}-${var.mysql_subnets[count.index]}"
#   }
# }
#
# resource "aws_route_table" "mysql-rt" {
#   count = length(var.mysql_subnets)
#   vpc_id = aws_vpc.dev.id
#
#   route {
#     cidr_block = "172.31.0.0/16"
#     vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
#   }
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat-igw[count.index].id
#   }
#
#   tags = {
#     Name = "${var.env}-mysql-rt${count.index+1}-${var.availability_zone[count.index]}-${var.mysql_subnets[count.index]}"
#   }
# }
#
# resource "aws_route_table_association" "mysql-rt-a" {
#   count          = length(var.mysql_subnets)
#   subnet_id      = aws_subnet.mysql[count.index].id
#   route_table_id = aws_route_table.mysql-rt[count.index].id
# }