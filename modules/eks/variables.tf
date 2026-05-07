variable "private_servers_subnet_id" {
  type        = string
  description = "ID of the private servers subnet for EKS cluster and node group."
}

variable "servers_sg_id" {
  type        = string
  description = "ID of the servers security group used by the EKS cluster."
}
