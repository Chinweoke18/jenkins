 #!/bin/bash -ex

  sudo yum update -y
  sudo amazon-linux-extras install java-openjdk11 -y
  sudo amazon-linux-extras install epel -y

  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
  sudo yum install jenkins -y

  sudo service jenkins start

  sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
  sudo start amazon-ssm-agent
  sudo chkconfig amazon-ssm-agent on