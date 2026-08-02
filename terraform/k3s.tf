resource "aws_instance" "k3s_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  subnet_id     = aws_subnet.public[0].id

  vpc_security_group_ids = [aws_security_group.k3s_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.k3s_profile.name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/userdata_k3s_server.sh", { project_prefix = var.project_prefix, region = var.aws_region })

  tags = {
    Name = "${var.project_prefix}-k3s-server"
  }
}

resource "aws_instance" "k3s_agent" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  subnet_id     = aws_subnet.public[1].id

  vpc_security_group_ids = [aws_security_group.k3s_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.k3s_profile.name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/userdata_k3s_agent.sh", { project_prefix = var.project_prefix, region = var.aws_region })

  tags = {
    Name = "${var.project_prefix}-k3s-agent"
  }
}
