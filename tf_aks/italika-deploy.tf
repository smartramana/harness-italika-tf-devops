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

output "ip_addresses" {
  value = ["${aws_instance.webserver.*.id}"]
}

resource "aws_instance" "webserver" {
  instance_type               = var.instance_type
  ami                         = "ami-02af0b5f66fbd511a"
  count                       = var.instance_count
  vpc_security_group_ids      = ["${aws_security_group.allow_ports.id}"]
  subnet_id                   = element(module.vpc.public_subnets, count.index)
  user_data                   = file("scripts/init.sh")
  associate_public_ip_address = true
}

resource "aws_route53_record" "server1-record" {
  zone_id = "Z04206741T94RD7FBT0G1"
  name    = "terraform.devopsday-harness.net"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.webserver.0.public_ip]
}
