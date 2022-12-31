# security groups

resource "aws_security_group" "terraform-sg" {
name        = "terraform-sg"
description = "Public Security Group"
vpc_id      = aws_vpc.vpc.id

ingress {
description      = "SSH Access"
from_port        = 22
to_port          = 22
protocol         = "tcp"
cidr_blocks      = ["0.0.0.0/0"]
}

ingress {
from_port   = 80
to_port     = 80
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
description      = "HTTP Access"
from_port        = 443
to_port          = 443
protocol         = "tcp"
cidr_blocks      = ["0.0.0.0/0"]
}

 egress {
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]

  }

 tags      = {
    Name   = "Terraform-SG"
  }

}

resource "aws_security_group" "rds-sg" {
    name = "rds-sg"
    vpc_id =  aws_vpc.vpc.id

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.terraform-sg.id]

    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }        

}


#----Security group for aws elb -----#

resource "aws_security_group" "terraform-elb-sg" {
    name = "terraform-elb-sg"
    vpc_id =  aws_vpc.vpc.id
    description = "security group for elb"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }  

     tags      = {
    Name   = "Terraform-elb-sg"
  }

}


#----Security group for aws instances -----#

resource "aws_security_group" "terraform-instance-sg" {
    name = "terraform-instance-sg"
    vpc_id =  aws_vpc.vpc.id
    description = "security group for instances"

    ingress {
        from_port = 22
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.terraform-elb-sg.id]

    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }  

     tags      = {
    Name   = "Terraform-instance-sg"
  }

}



