
locals {
 jenkins_cluster = {
      "jenkins_master" = { instance_count = "1", instance_type = "t2.micro", aws_subnet = aws_subnet.private[0].id, data_file = "${file("./scripts/install_jenkins-and-ssm.sh")}" },
      "java_slave" = { instance_count = "1", instance_type = "t2.micro", aws_subnet = aws_subnet.private[1].id, data_file = "${file("./scripts/install_java-agent-and-ssm.sh")}" }
 }
}

module "ec2" {
    source = "./modules/ec2"

    for_each = local.jenkins_cluster
     
    instance_count          = each.value.instance_count
    instance_type           = each.value.instance_type
    aws_subnet              = each.value.aws_subnet
    data_file               = each.value.data_file
    security_grp_ids        = [aws_security_group.jenkins_sg.id]
    iam_instance_profile    = aws_iam_instance_profile.resources-iam-profile.name
   
}

resource "aws_security_group" "jenkins_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_instance_profile" "resources-iam-profile" {
  name = "ec2_profile"
  role = aws_iam_role.resources-iam-role.name
}

resource "aws_iam_role" "resources-iam-role" {
  name        = "ec2-ssm-role"
  description = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
  {
  "Version": "2012-10-17",
  "Statement": {
  "Effect": "Allow",
  "Principal": {"Service": "ec2.amazonaws.com"},
  "Action": "sts:AssumeRole"
  }
  }
  EOF
  tags = {
    stack = "test"
  }
}

resource "aws_iam_role_policy_attachment" "resources-ssm-policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", 
    "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  ])

  role       = aws_iam_role.resources-iam-role.name
  policy_arn = each.value
}

