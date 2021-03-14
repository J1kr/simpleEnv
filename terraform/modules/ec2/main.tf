# ec2 EC2
resource "aws_instance" "ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  availability_zone      = var.availability_zone
  subnet_id              = var.subnet_id
  key_name               = var.keypair_name
  vpc_security_group_ids = [aws_security_group.Internel.id]

  associate_public_ip_address = false
  
  root_block_device {
        volume_type           = "gp2"
        volume_size           = "8"
        delete_on_termination = true

        tags = merge(var.tags, map("Name", format("%s-Private", var.name)))
    }
  tags = merge(var.tags, map("Name", format("%s-Private", var.name)))
}


resource "aws_security_group" "Internel" {
  name        = "Internel"
  description = "Allow connect to Internel"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.ingress_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, map("Name", format("%s-Network", var.name)))
}

