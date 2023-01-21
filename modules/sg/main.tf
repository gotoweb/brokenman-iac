resource "aws_security_group" "allow_http_https" {
  name = "allow_http_https"
  description = "allow HTTP, HTTPS"
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 443
    protocol = "tcp"
    to_port = 443
  }

  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
}