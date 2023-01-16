resource "aws_instance" "jenkins_cluster" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = var.instance_type
  key_name      = "jenkins-kp"

  count                       = var.instance_count
  subnet_id                   = var.aws_subnet
  vpc_security_group_ids      = var.security_grp_ids
  associate_public_ip_address = false
  disable_api_termination     = true
  iam_instance_profile        = var.iam_instance_profile

  
  root_block_device {
    delete_on_termination = true
    iops = 150
    volume_size = 110
    volume_type = "gp3"
  }


  user_data = var.data_file

  tags = {
    "Name" : "Jenkins"
    "Createdby" : "chinweoke"
  }
}