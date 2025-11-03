# Outside interface
resource "aws_network_interface" "eth0" {
  description = "fgtvm-port1"
  subnet_id   = aws_subnet.snet-pub1.id
}

# Inside interface
resource "aws_network_interface" "eth1" {
  description       = "fgtvm-port2"
  subnet_id         = aws_subnet.snet-priv1.id
  source_dest_check = false
}

resource "aws_network_interface_sg_attachment" "attach-outside" {
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.eth0.id
}

resource "aws_network_interface_sg_attachment" "attach-inside" {
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.eth1.id
}

resource "aws_network_interface_sg_attachment" "attach-bastion" {
  security_group_id    = aws_security_group.public_allow.id
  network_interface_id = aws_network_interface.eni-bastion.id
}

resource "aws_network_interface" "eni-bastion" {
  description = "bastion eni"
  subnet_id   = aws_subnet.snet-pub1.id
}

resource "aws_instance" "bastion" {
  ami           = "ami-08982f1c5bf93d976"
  instance_type = "t3.micro"
  key_name      = var.keyname

  primary_network_interface {
    network_interface_id = aws_network_interface.eni-bastion.id
  }

  tags = {
    Name = "e1-bastion"
  }
}

resource "aws_network_interface" "eni-web01" {
  description = "web-01 eni"
  subnet_id   = aws_subnet.snet-priv1.id
}

resource "aws_network_interface_sg_attachment" "attach-web01" {
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.eni-web01.id
}

resource "aws_instance" "web01" {
  ami           = "ami-08982f1c5bf93d976"
  instance_type = "t3.micro"
  key_name      = var.keyname

  primary_network_interface {
    network_interface_id = aws_network_interface.eni-web01.id
  }

  tags = {
    Name = "e1-web01"
  }
}

# Cloudinit config in MIME format
data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  # Main cloud-config configuration file.
  part {
    filename     = "config"
    content_type = "text/x-shellscript"
    content = templatefile("${var.bootstrap-fgtvm}", {
      adminsport = var.adminsport
    })
  }

  part {
    filename     = "license"
    content_type = "text/plain"
    content      = file("${var.license}")
  }
}

resource "aws_instance" "fgtvm" {
  ami           = "ami-0d8ab3309f7946a19"
  instance_type = var.size
  key_name      = var.keyname
  user_data     = data.cloudinit_config.config.rendered

  root_block_device {
    volume_type = "gp2"
    volume_size = "2"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "gp2"
  }

  primary_network_interface {
    network_interface_id = aws_network_interface.eth0.id
  }

  tags = {
    Name = "e1-fghub-01"
  }
}

resource "aws_network_interface_attachment" "eni-attach" {
  instance_id          = aws_instance.fgtvm.id
  network_interface_id = aws_network_interface.eth1.id
  device_index         = 1
}