# 1. Public LB Subnet (ports 80/443 only) 

resource "aws_subnet" "public_lb" {
vpc_id = aws_vpc.main.id
cidr_block = "10.0.1.0/24"
availability_zone = "us-east-1a"
map_public_ip_on_launch = true # Any instance launched here will get a public IP automatically.
tags = { Name = "malaa-public-lb" }
}

# 2. Private DMZ Subnet (firewall/IDS — ports 80/443 in, open out) 

resource "aws_subnet" "private_dmz" {
vpc_id = aws_vpc.main.id
cidr_block = "10.0.2.0/24"
availability_zone = "us-east-1a"
tags = { Name = "malaa-private-dmz" }
}

# 3. Private Servers Subnet (ports 80/443/22 in, open out) 

resource "aws_subnet" "private_servers" {
vpc_id = aws_vpc.main.id
cidr_block = "10.0.3.0/24"
availability_zone = "us-east-1a"
tags = { Name = "malaa-private-servers" }
}

# 4. Private Database Subnet (ports 8080/26257 only) 

resource "aws_subnet" "private_database" {
vpc_id = aws_vpc.main.id
cidr_block = "10.0.4.0/24"
availability_zone = "us-east-1a"
tags = { Name = "malaa-private-db" }
}