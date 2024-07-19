data "aws_ami" "rhel_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-9.4.0_HVM-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["309956199498"] # RHEL
}

resource "aws_key_pair" "aws_key" {
  key_name   = "aws-key"
  public_key = file(var.public_key_file)
}


resource "aws_instance" "salt_master" {
  ami                    = data.aws_ami.rhel_ami.id
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
    "./scripts/salt-install.tftpl",
    {
      instance         = "master",
      master_public_ip = aws_eip.master_eip.public_ip,
      minion_index     = null
    }
  )
}

resource "aws_instance" "salt_minion" {
  count                       = var.minion_count
  ami                         = data.aws_ami.rhel_ami.id
  instance_type               = "t2.small"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.aws_key.key_name
  vpc_security_group_ids      = [aws_security_group.saltstack_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = "Salt-Minion-${count.index + 1}"
  }

  user_data = templatefile(
    "./scripts/salt-install.tftpl",
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

resource "aws_eip" "master_eip" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.salt_master.id
  allocation_id = aws_eip.master_eip.id
}

resource "null_resource" "wait_for_bootstrap_to_finish" {
  provisioner "local-exec" {
    command = <<-EOF
    alias ssh='ssh -q -i ${var.private_key_file} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    while true; do
      if ssh ec2-user@${aws_eip.master_eip.public_ip} [[ -f /home/ec2-user/done ]]; then
        echo "Bootstrap completed in the Master"
        break
      else
        echo "Waiting for bootstrap completion in the Master"
        sleep 5
        continue
      fi
    done
    
    %{for worker_public_ip in aws_instance.salt_minion[*].public_ip~}
      while true; do
      if ssh ec2-user@${worker_public_ip} [[ -f /home/ec2-user/done ]]; then
        echo "Bootstrap completed in the Minion: ${worker_public_ip}"
        break
      else
        echo "Waiting for bootstrap completion in the Minion: ${worker_public_ip}"
        sleep 5
        continue
      fi
      done
    %{endfor~}

    ssh ec2-user@${aws_eip.master_eip.public_ip} sudo salt-key -A -y
    EOF
  }
  triggers = {
    instance_ids = join(",", concat([aws_instance.salt_master.id], aws_instance.salt_minion[*].id))
  }
}