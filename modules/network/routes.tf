# Public route table → Internet Gateway
# Send ALL traffic to the internet via Internet Gateway

resource "aws_route_table" "public" {
vpc_id = aws_vpc.main.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.igw.id
}
tags = { Name = "malaa-public-rt" }
}

resource "aws_route_table_association" "public_lb" {
subnet_id = aws_subnet.public_lb.id
route_table_id = aws_route_table.public.id
}

# Private route table (no internet route)

resource "aws_route_table" "private" {
vpc_id = aws_vpc.main.id
tags = { Name = "malaa-private-rt" }
}

resource "aws_route_table_association" "dmz" {
subnet_id = aws_subnet.private_dmz.id
route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "servers" {
subnet_id = aws_subnet.private_servers.id
route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
subnet_id = aws_subnet.private_database.id
route_table_id = aws_route_table.private.id
}