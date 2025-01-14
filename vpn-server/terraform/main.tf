terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Find the latest AMI for a given OS
data "aws_ami" "search" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  name_regex = var.amis_os_map_regex
  owners     = [var.amis_primary_owner]
}

output "ami_id" {
  description = "The AMI id result of the search"
  value       = data.aws_ami.search.id
}

data "aws_vpc" "cluster" {
  id = data.aws_subnet.selected.vpc_id
}

data "aws_subnet" "selected" {
  id = var.subnet_cluster
}

data "aws_internet_gateway" "selected" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_subnet.selected.vpc_id]
  }
}

resource "aws_subnet" "vpn_server_subnet" {
  vpc_id                  = data.aws_subnet.selected.vpc_id
  cidr_block              = var.vpn_subnet_cidr
  availability_zone       = data.aws_subnet.selected.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name   = "vpn-subnet"
    Policy = "skip"
  }
}

resource "aws_route_table" "vpn_route_table" {
  vpc_id = data.aws_subnet.selected.vpc_id

  tags = {
    Name   = "vpn-route-table"
    Policy = "skip"
  }
}

resource "aws_route" "route_to_igw" {
  route_table_id         = aws_route_table.vpn_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.selected.id
}

resource "aws_route_table_association" "vpn_route_table_association" {
  subnet_id      = aws_subnet.vpn_server_subnet.id
  route_table_id = aws_route_table.vpn_route_table.id
}

resource "aws_security_group" "server-security-group" {
  name        = "server-sg"
  description = "Used in the terraform"
  vpc_id      = data.aws_subnet.selected.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "internal-security-group" {
  name        = "server-sg-internal"
  description = "Used for server internal communication with clusters"
  vpc_id      = data.aws_subnet.selected.vpc_id

  # allow all inbound traffic from all in this VPC all vpc blocks
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.cluster.cidr_block]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_network_interface" "vpn_interface" {
  description       = "Interface in the VPN subnet"
  subnet_id         = aws_subnet.vpn_server_subnet.id
  security_groups   = [aws_security_group.server-security-group.id]
  source_dest_check = false

  tags = {
    Name   = "vpn-interface"
    Policy = "skip"
  }
}

resource "aws_network_interface" "cluster_interface" {
  description       = "Interface in the cluster subnet"
  subnet_id         = var.subnet_cluster
  security_groups   = [aws_security_group.internal-security-group.id]
  source_dest_check = false

  tags = {
    Name   = "cluster-interface"
    Policy = "skip"
  }
}

resource "aws_eip" "vpn_interface_eip" {
  vpc = true
  tags = {
    Name   = "vpn-interface-eip"
    Policy = "skip"
  }
}

resource "aws_eip_association" "vpn_interface_eip_assoc" {
  allocation_id        = aws_eip.vpn_interface_eip.id
  network_interface_id = aws_network_interface.vpn_interface.id
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.search.id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = merge(var.server_additional_tags,
    {
      ManagedBy = "TelcoCI team",
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.vpn_interface.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.cluster_interface.id
    device_index         = 1
  }

  connection {
    type        = "ssh"
    user        = var.ami_user
    private_key = file(var.private_key_path)
    host        = aws_eip.vpn_interface_eip.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install epel -y",
      "sudo yum install openvpn easy-rsa vim wget tcpdump -y",
      "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf",
      "sudo sysctl -p",
      "sudo ip link set eth1 up",
      "sudo pkill dhclient",
      "sudo dhclient eth1",
      "sudo ip route delete default dev eth1",
      "sudo pkill dhclient",
      "sudo dhclient eth0",
      <<-EOF
      sudo bash -c 'cat > /etc/sysconfig/network-scripts/ifcfg-eth1 <<EOL
      DEVICE=eth1
      BOOTPROTO=dhcp
      ONBOOT=yes
      TYPE=Ethernet
      USERCTL=yes
      PEERDNS=yes
      DHCPV6C=yes
      DHCPV6C_OPTIONS=-nw
      PERSISTENT_DHCLIENT=yes
      RES_OPTIONS="timeout:2 attempts:5"
      DHCP_ARP_CHECK=no
      DEFROUTE=no
      EOL'
      EOF
      ,
      "sudo systemctl restart network",

    ]
  }
}


output "vpn_interface_public_ip" {
  value = aws_eip.vpn_interface_eip.public_ip
}
