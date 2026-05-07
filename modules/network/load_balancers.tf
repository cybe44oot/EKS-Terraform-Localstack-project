#  1. Public ALB (internet-facing) 

resource "aws_lb" "public" {
name = "malaa-public-alb"
internal = false
load_balancer_type = "application"
security_groups = [aws_security_group.public_lb.id]
subnets = [aws_subnet.public_lb.id]
tags = { Name = "malaa-public-alb" }
}

resource "aws_lb_target_group" "public" {
name = "tg-public"
port = 80
protocol = "HTTP"
vpc_id = aws_vpc.main.id
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public.arn
  }
}

#  2. Private ALB for Web Servers 

resource "aws_lb" "private_servers" {
name = "malaa-private-servers-alb"
internal = true
load_balancer_type = "application"
security_groups = [aws_security_group.servers.id]
subnets = [aws_subnet.private_servers.id]
tags = { Name = "malaa-private-servers-alb" }
}

resource "aws_lb_target_group" "servers" {
name = "tg-servers"
port = 80
protocol = "HTTP"
vpc_id = aws_vpc.main.id
}

#  3. Private NLB for Database 

resource "aws_lb" "private_db" {
name = "malaa-private-db-nlb"
internal = true
load_balancer_type = "network"
subnets = [aws_subnet.private_database.id]
tags = { Name = "malaa-private-db-nlb" }
}

resource "aws_lb_target_group" "db" {
name = "tg-db"
port = 26257
protocol = "TCP"
vpc_id = aws_vpc.main.id
}