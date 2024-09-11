
# Create Security Group for compute http access
resource "aws_security_group" "allow-http" {
  name  = "allow-http"
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
data "aws_vpc_security_group_rule" "sg_rule_data" {
  security_group_rule_id = aws_vpc_security_group_ingress_rule.allow-http.id
}

check "check_ssh_ingress" {  
  assert {
    condition = (
      data.aws_vpc_security_group_rule.sg_rule_data.is_egress==false && 
      data.aws_vpc_security_group_rule.sg_rule_data.from_port == 80 &&
      data.aws_vpc_security_group_rule.sg_rule_data.to_port == 80 &&
      data.aws_vpc_security_group_rule.sg_rule_data.ip_protocol=="tcp"
    )
    error_message = "SSH connection is not enabled on VPC Security Group"
  }
}