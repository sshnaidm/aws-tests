variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "subnet_cluster" {
  description = "ID of subnet where cluster is deployed"
  type        = string
}

variable "vpn_subnet_cidr" {
  description = "CIDR block for VPN subnet"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "server_additional_tags" {
  description = "Tags for each server"
  type        = map(any)
}

variable "ami_user" {
  description = "User to use for AMI"
  default     = "ec2-user"
}

variable "amis_os_map_regex" {
  description = "Regex to search amis"
}

variable "amis_primary_owner" {
  description = "Owner of the AMI"
  default     = "amazon"
}

variable "instance_type" {
  description = "Instance type"
}

variable "aws_profile" {
  description = "AWS profile"
}

variable "private_key_path" {
  description = "Path to private key"
  type        = string
  default     = "~/.ssh/id_rsa"
}
