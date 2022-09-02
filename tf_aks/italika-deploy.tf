resource "aws_security_group" "allow_ports" {
  name        = "allow_ssh_http"
  description = "Allow inbound SSH traffic and http from any IP"
  vpc_id      = module.vpc.vpc_id

  #ssh access
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    # Restrict ingress to necessary IPs/ports.
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    # Restrict ingress to necessary IPs/ports.
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


variable "aws_amis" {
  default = {
    us-east-2 = "ami-02af0b5f66fbd511a"
    eu-west-2 = "ami-095ed825090131933"
  }
}

variable "instance_type" {
  description = "Type of AWS EC2 instance."
  default     = "t2.micro"
}

variable "instance_count" {
  default = 1
}

output "vpc_id" {
  value = ["${module.vpc.vpc_id}"]
}

output "vpc_public_subnets" {
  value = ["${module.vpc.public_subnets}"]
}

output "webserver_ids" {
  value = ["${aws_instance.webserver.*.id}"]
}



resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxTw8+MwTcNU6bCo19plPEuQIA5pneOrxfhRd0UTgC5EzCznf1H6QUqBDaFHqDF5Fv4j2qONLbVH0ybTcX+o7ZL937aTgzwPMgsDeBvEWsuyqXSfYqIw8f1PZXxZlhAy6Aeg80uVeD8bRMen+q2IZJMnvYK2JMujE+Z6JakvVcBx6JRQbGUDgh0VVfhWJBbr1nTcOQJ1Mg7n7QMgwiOxAybzTr+WtgvpQCxJNOhZ+QgETOqZyjtojkp8SnkJs39B++1Pn1ADwm7AspUTT5iX3U/NCKDiXxz4mPv9+whlZv/qDSUQp98ZE4WOoT9J5nRHLFTn4r3AmAeCHDnfhxm6e6ylXl5+GI52H44MXqACTZjdjvo0LYGXEDhVJ4DDZS+/tmxXhnqAlPe9SLx34Hcg4OSmtgaEh2KuB2/ye/Ffb4xRd/0wswNhFGJVO4rNBAosqJPyScb6oOx9XIZxCdy8ncZi1/Q1Dq6RoIw3jUqy80G+3M2eXPrKK1dqetMuoz0ys= cristianramirez@MacBook-Pro-de-Cristian.local"
}

resource "aws_instance" "webserver" {
  instance_type               = var.instance_type
  ami                         = "ami-05803413c51f242b7"
  count                       = var.instance_count
  vpc_security_group_ids      = ["${aws_security_group.allow_ports.id}"]
  subnet_id                   = element(module.vpc.public_subnets, count.index)
  user_data                   = file("scripts/init.sh")
  associate_public_ip_address = true
  key_name                    = "ssh-key"
}

resource "aws_elb" "main" {
  name               = "terraform-elb"
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances = [aws_instance.webserver.0.id]
}

resource "aws_route53_record" "www" {
  zone_id = "Z04206741T94RD7FBT0G1"
  name    = "terraform-lb"
  type    = "A"

  alias {
    name                   = aws_elb.main.dns_name
    zone_id                = aws_elb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "server1-record" {
  zone_id = "Z04206741T94RD7FBT0G1"
  name    = "terraform"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.webserver.0.public_ip]
}


output "ip_addresses" {
  value = {
    public_ip = aws_instance.webserver.0.public_ip
    elb       = aws_elb.main.dns_name
    tf        = "terraform.devopsday-harness.net"
    tf_elb    = "terraform-lb.devopsday-harness.net"
  }
}
