
# Create Security Group for compute http access
variable "sg_name" {
  default = "allow-http"
}

resource "aws_security_group" "allow-http" {
  name  = var.sg_name
}

# Security Group - Ingress Rule
resource "aws_vpc_security_group_ingress_rule" "allow-http" {
  security_group_id = aws_security_group.allow-http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Security Group - Egress Rule
resource "aws_vpc_security_group_egress_rule" "allow-all-traffic" {
  security_group_id = aws_security_group.allow-http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

data "aws_vpc_security_group_rule" "sg_rule" {
  filter {
    name ="group-id"
    values = [aws_security_group.allow-http.id]
  }
}

output "rule_out" {
  value = data.aws_vpc_security_group_rule.sg_rule
}


check "check_http_ingress" {  
  assert {
    condition = (
      data.aws_vpc_security_group_rule.sg_rule.from_port == "80"
    )
    error_message = "HTTP connection is not enabled on VPC Security Group"
  }
}