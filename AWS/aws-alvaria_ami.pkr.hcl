packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.3"
      source  = "github.com/hashicorp/amazon"
    }
    vagrant = {
      source = "github.com/hashicorp/vagrant"
      version = ">= 1.0.0"
    }
  }
}

variable "host_type" {
  type    = string
  default = "fortress"
}

variable "volume_size" {
  type    = number
  default = 105
}

variable "opt_partition" {
  type    = string
  default = "20G"
}

variable "var_opt_partition" {
  type    = string
  default = "55G"
}

variable "nsclogserver_partition" {
  type    = string
  default = "0G"
}

variable "pg_partition" {
  type    = string
  default = "+100%FREE"
}


source "amazon-ebs" "alvaria-alma9" {
  access_key = ""
  secret_key = ""
  instance_type = "t3.xlarge"
  region        = "us-east-1"
  source_ami    = "ami-03d9aef787dba1e76"
  ssh_username  = "ec2-user"
  ami_virtualization_type = "hvm"
  ami_name        = "Alvaria-Host-{{timestamp}}"
  ami_description = "Alvaria-Host"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 45
    volume_type           = "gp2"
    delete_on_termination = true
  }

  launch_block_device_mappings {
    device_name           = "/dev/sdb"
    volume_size           = var.volume_size  # Use var.volume_size correctly here
    volume_type           = "gp2"
    delete_on_termination = true
  }
}

build {
  name   = "alvaria-core-basic"
  sources = ["source.amazon-ebs.alvaria-alma9"]

  provisioner "file" {
    source      = "./scripts/disk_partition.sh"
    destination = "/tmp/provision.sh"
  }
  provisioner "file" {
    source      = "./scripts/install.sh"
    destination = "/tmp/install.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/provision.sh /tmp/install.sh",
      "/tmp/provision.sh ${var.host_type} ${var.volume_size} ${var.opt_partition} ${var.var_opt_partition}  ${var.nsclogserver_partition} ${var.pg_partition}",
      "/tmp/install.sh",
      "sudo /opt/alvaria/alvaria-cx-install/bin/install --no-dry-run --no-ntp --no-harden-me core/${var.host_type}"
    ]
  }

  post-processor "manifest" {
    output = "manifest-{{timestamp}}-{{build_name}}.json"
  }

  post-processor "vagrant" {}
  post-processor "compress" {}
}
