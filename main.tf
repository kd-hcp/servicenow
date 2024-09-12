
variable "server_message" {
    type = string
    description = "Message displayed on server."
    default = "Hello!"
}

# Retrieve the proper machine image for EC2 instance
data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Create AWS Compute Instance 
resource "aws_instance" "ec2_test" {
  ami           = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = "t2.micro"

  security_groups = [aws_security_group.allow-http.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo ${var.server_message} > /var/www/html/index.html
              EOF

  tags = {
    Name = "EC2 TF.Test"
  }
}

output "aws_instance_ip" {
  value = aws_instance.ec2_test.public_ip
  description = "Public IP address for web access"
}

check "check_http_ingress" {  
  assert {
    condition     = anytrue([for sg in aws_instance.ec2_test.vpc_security_group_ids : 
                              length(
                                [for rule in aws_security_group.allow-http.ingress : 
                                  rule if rule.from_port == 80 && rule.to_port == 80 && rule.protocol == "tcp"]
                              ) > 0])
    error_message = "HTTP connection is not enabled on VPC Security Group"
  }
}