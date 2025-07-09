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