resource "aws_instance" "ubuntu_salt_minion" {
  count                       = var.ubuntu_minion_count
  ami                         = data.aws_ami.ubuntu_ami.id
  instance_type               = "t2.small"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.aws_key.key_name
  vpc_security_group_ids      = [aws_security_group.saltstack_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = "Ubuntu-Salt-Minion-${count.index + 1}"
  }

  user_data = templatefile(
    "${path.root}/${path.module}/scripts/salt-install-ubuntu.tftpl",
    {
      instance         = "minion",
      master_public_ip = aws_eip.master_eip.public_ip,
      minion_index     = count.index + 1
    }
  )

  depends_on = [
    aws_instance.salt_master
  ]
}

resource "aws_instance" "rhel_salt_minion" {
  count                       = var.rhel_minion_count
  ami                         = data.aws_ami.amazon_ami.id
  instance_type               = "t2.small"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.aws_key.key_name
  vpc_security_group_ids      = [aws_security_group.saltstack_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = "RHEL-Salt-Minion-${count.index + 1}"
  }

  user_data = templatefile(
    "${path.root}/${path.module}/scripts/salt-install-rhel.tftpl",
    {
      instance         = "minion",
      master_public_ip = aws_eip.master_eip.public_ip,
      minion_index     = count.index + 1
    }
  )

  depends_on = [
    aws_instance.salt_master
  ]
}

resource "null_resource" "bootstrap_ubuntu_minions" {
  depends_on = [null_resource.master_bootstrap]
  for_each   = { for idx, instance in aws_instance.ubuntu_salt_minion : idx => instance }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_file)
    host        = each.value.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /home/ubuntu/done ]; do",
      "  echo 'Waiting for bootstrap completion in the Minion: ${each.value.public_ip}'",
      "  sleep 5",
      "done",
      "echo 'Bootstrap completed in the Minion: ${each.value.public_ip}'"
    ]
  }
  triggers = {
    instance_id = each.value.id
  }
}

resource "null_resource" "bootstrap_rhel_minions" {
  depends_on = [null_resource.master_bootstrap]
  for_each   = { for idx, instance in aws_instance.rhel_salt_minion : idx => instance }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_file)
    host        = each.value.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /home/ec2-user/done ]; do",
      "  echo 'Waiting for bootstrap completion in the Minion: ${each.value.public_ip}'",
      "  sleep 5",
      "done",
      "echo 'Bootstrap completed in the Minion: ${each.value.public_ip}'"
    ]
  }
  triggers = {
    instance_id = each.value.id
  }
}