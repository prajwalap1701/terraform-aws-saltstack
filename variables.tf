variable "private_key_file" {
  type        = string
  description = "SSH Private key on local machine to connect to the Instances"
  default     = "./keys/aws-key"
}

variable "public_key_file" {
  type        = string
  description = "SSH Public key on local machine to connect to the Instances"
  default     = "./keys/aws-key.pub"
}

# Define a variable for the number of Minions
variable "minion_count" {
  type        = number
  default     = 2
  description = "Number of Salt Minions"
}