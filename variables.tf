variable "private_key_file" {
  type        = string
  description = "SSH Private key path on local machine to connect to the Instances"
  default     = "~/.ssh/id_rsa"
}

variable "public_key_file" {
  type        = string
  description = "SSH Public key path on local machine to connect to the Instances"
  default     = "~/.ssh/id_rsa.pub"
}

# Define a variable for the number of Ubuntu Minions
variable "ubuntu_minion_count" {
  type        = number
  default     = 1
  description = "Number of Ubuntu Salt Minions"
}

# Define a variable for the number of RHEL Minions
variable "rhel_minion_count" {
  type        = number
  default     = 1
  description = "Number of RHEL Salt Minions"
}