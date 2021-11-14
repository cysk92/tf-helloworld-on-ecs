resource "aws_vpc" "main" {
  cidr_block = "10.194.0.0/16"
}

resource "aws_subnet" "public-subnet" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private-subnet" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.main.id
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet-gateway.id
}

resource "aws_eip" "eip-gateway" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.internet-gateway]
}

resource "aws_nat_gateway" "nat-gateway" {
  count         = 2
  subnet_id     = element(aws_subnet.public-subnet.*.id, count.index)
  allocation_id = element(aws_eip.eip-gateway.*.id, count.index)
}

resource "aws_route_table" "private-routes" {
  count  = 2
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat-gateway.*.id, count.index)
  }
}

resource "aws_route_table_association" "private-route-association" {
  count          = 2
  subnet_id      = element(aws_subnet.private-subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private-routes.*.id, count.index)
}

resource "aws_security_group" "loadbalancer-sg" {
  name        = "kantox-alb-security-group"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "helloworld-task-sg" {
  name        = "kantox-task-security-group"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = [aws_security_group.loadbalancer-sg.id]
  }
  
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "loadbalancer" {
  name            = "kantox-lb"
  subnets         = aws_subnet.public-subnet.*.id
  security_groups = [aws_security_group.loadbalancer-sg.id]
}

resource "aws_lb_target_group" "helloworld-tg" {
  name        = "kantox-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_listener" "helloworld-listener" {
  load_balancer_arn = aws_lb.loadbalancer.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.helloworld-tg.id
    type             = "forward"
  }
}
