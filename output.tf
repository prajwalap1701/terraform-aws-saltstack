output "salt_instances" {
  value = [
    for i in concat([aws_instance.salt_master], aws_instance.salt_minion, ) : {
      name       = i.tags["Name"]
      public_ip  = i.tags["Name"] == "master" ? aws_eip.master_eip.public_ip : i.public_ip
    }
  ]
  description = "Name, public IP address of all Salt instances."
}