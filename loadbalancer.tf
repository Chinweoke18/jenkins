# alb.tf

resource "aws_alb" "main" {
  name            = "${var.app_name}-${var.app_environment}-alb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "lb" {
  name        = "${var.app_name}-${var.app_environment}-sg"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
   }

  ingress {
   protocol         = "tcp"
   from_port        = 443
   to_port          = 443
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Target group
resource "aws_alb_target_group" "jenkins-tg" {
  name        = "jenkins-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
# resource "aws_alb_listener" "jenkins-alb-listener" {
#   load_balancer_arn = aws_alb.main.id
#   port              = var.app_port
#   protocol          = "HTTP"

#   default_action {
#     target_group_arn = aws_alb_target_group.jenkins-tg.id
#     type             = "forward"
#   }
# }

resource "aws_alb_listener" "jenkins-alb-listener" {
  load_balancer_arn = aws_alb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = "arn:aws:acm:us-east-1:597433640467:certificate/ac375cee-438d-4b75-be23-c2c026eef052"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.jenkins-tg.arn
  }
}

resource "aws_alb_target_group_attachment" "jenkins-target" {
  for_each = local.jenkins_cluster
  target_group_arn = aws_alb_target_group.jenkins-tg.arn
  target_id        = module.ec2.instance_private_IPs[0]
  # target_id        = module.ec2.instance_private_IP   
  port             = 8080

  depends_on = [module.ec2.instance]
}

resource "aws_route53_record" "jenkins-hostname" {
  zone_id = "Z084194513HL6RZJI075U"
  name    = "jenkins.paycontactles.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_alb.main.dns_name]

  depends_on = [aws_alb.main]
}