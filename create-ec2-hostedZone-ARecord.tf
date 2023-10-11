terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

#------------------------
# Update the default VPC security group
#------------------------
# This works

resource "aws_default_security_group" "default" {
vpc_id = "vpc-026ecc2b2d5c3fb8a"

  ingress {
    description    = "Allow TCP inbound on port 22"
    protocol       = "tcp"
    cidr_blocks    = ["0.0.0.0/0"]
  # from_port      = 0
    to_port        = 22
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#------------------------
# Create EC2 instance
#------------------------
resource "aws_instance" "trevor_server" {
  ami           = "ami-067d1e60475437da2"
  instance_type = "t2.micro"

  tags = {
    Name = "test-ec2"
  }
}

#------------------------
# Create public hosted zone
#------------------------
resource "aws_route53_zone" "primary" {
  name = "walshtrev.com"

  tags = {
    Name = "test-zone"
  }
}

#----------------------------------------------------------------------------------------------------
# Create A record in public hosted zone. The public IP of the "trevor_server" will be added as A record value
#----------------------------------------------------------------------------------------------------
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "walshtrev.com"
  type    = "A"
  ttl     = 300
  records = [aws_instance.trevor_server.public_ip]
}

#------------------------------------------------------------------
# Create Test A record pointing to my 'TrevorWaslshArt' Lightsail instance
#------------------------------------------------------------------
resource "aws_route53_record" "twart" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "twart.walshtrev.com"
  type    = "A"
  ttl     = 300
  records = ["52.209.123.222"]
}

# records = ["1.2.3.4"]
