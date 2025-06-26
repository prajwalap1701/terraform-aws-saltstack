resource "aws_key_pair" "aws_key" {
  key_name   = "aws-key"
  public_key = file(var.public_key_file)
}


resource "aws_instance" "salt_master" {
  ami                    = data.aws_ami.ubuntu_ami.id
  instance_type          = "t2.small"
  key_name               = aws_key_pair.aws_key.key_name
  vpc_security_group_ids = [aws_security_group.saltstack_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = "Salt-Master"
  }

  user_data = templatefile(
    "${path.root}/${path.module}/scripts/salt-install-ubuntu.tftpl",
    {
      instance         = "master",
      master_public_ip = aws_eip.master_eip.public_ip,
      minion_index     = null
    }
  )
}

resource "aws_eip" "master_eip" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.salt_master.id
  allocation_id = aws_eip.master_eip.id
}

resource "null_resource" "master_bootstrap" {
  depends_on = [aws_instance.salt_master]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_file)
    host        = aws_eip.master_eip.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /home/ubuntu/done ]; do",
      "  echo 'Waiting for bootstrap completion in the Master'",
      "  sleep 5",
      "done",
      "echo 'Bootstrap completed in the Master'"
    ]
  }

  triggers = {
    instance_id = aws_instance.salt_master.id
  }
}


resource "null_resource" "accept_all_keys" {
  depends_on = [
    null_resource.master_bootstrap,
    null_resource.bootstrap_ubuntu_minions,
    null_resource.bootstrap_rhel_minions
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_file)
    host        = aws_eip.master_eip.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo salt-key -A -y",
      "echo 'All keys accepted.'"
    ]
  }
}
