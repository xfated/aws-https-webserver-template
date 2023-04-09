resource "aws_lb" "load_balancer" {
  name               = "${local.project_name}-lb-web-proxy"
  internal           = false // Set it to be internet facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-sg.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id] // Attach subnets to load balancer
}

// Define the security rules for traffic to your load balancer
resource "aws_security_group" "web-sg" {
  name        = "${local.project_name}-lb-proxy-sg"
  description = "Load balancer security firewall"
  vpc_id      = aws_vpc.main_vpc.id

  // Inbound HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Inbound HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.project_name}-lb-sg"
  }
}

// Specify a group for your load balancer to forward traffic to. 
// This target group will be used to contain your ec2 instance
resource "aws_lb_target_group" "ec2_server_target_group" {
  name     = "${local.project_name}-lb-tg"
  port     = 80 // Using HTTP here as we are setting up HTTPS in front of the load balancer, not within the VPC
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  lifecycle {
    create_before_destroy = true
  }

  // Specify where the load balancer should verify the status of your application
  health_check {
    path    = "/healthcheck"
    matcher = "200" # Check for Status Code 200 OK
  }
}

// Attach ec2 instance to a target_group
// This is where you specify which group your ec2 instances belong to for load balancing
resource "aws_lb_target_group_attachment" "ec2_group_attachment" {
  for_each = local.public_subnets

  target_group_arn = aws_lb_target_group.ec2_server_target_group.arn
  target_id        = aws_instance.ec2_server_instance[each.key].id
}

// Set up listeners on your load balancer for routing the incoming traffic
// Redirect HTTP requests (port 80) to HTTPS (port 443)
resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

// Forward all HTTPS requests to your target group (with your ec2 instance) 
resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.tls_cert.arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-0-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_server_target_group.arn
  }
}