variable "host_type" {
  default = "basic"
}

source "amazon-ebs" "alvaria-alma9" {
  access_key = ""
  secret_key = ""

  instance_type = "t3.xlarge"
  region        = "us-east-1"
  source_ami    = "ami-03d9aef787dba1e76"
  ssh_username  = "ec2-user"
  ami_virtualization_type = "hvm"
  ami_name                   = "Alvaria-${upper(var.host_type)}"
  ami_description            = "Alvaria-${upper(var.host_type)}"


  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  launch_block_device_mappings {
    device_name           = "/dev/sdb"
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }
}
build {
  name   = "alvaria-core-${upper(var.host_type)}"
  sources = ["source.amazon-ebs.alvaria-alma9"]

  provisioner "shell" {
    inline = [
      "sudo yum install -y cloud-utils-growpart lvm2",
      "sudo lsblk",
      "sudo vgs",
      "DEVICE=$(lsblk | grep '25G  0 disk' | awk '{print $1}')",
      "sudo pvcreate /dev/$DEVICE",
      "sudo vgcreate alvaria /dev/$DEVICE",
      "sudo lvcreate -L 5G -n opt alvaria",
      "sudo lvcreate -L 5G -n var_opt alvaria",
      "sudo lvcreate -L 5G -n var_lib_pgsql alvaria",
      "sudo mkfs.xfs /dev/alvaria/opt",
      "sudo mkfs.xfs /dev/alvaria/var_opt",
      "sudo mkfs.xfs /dev/alvaria/var_lib_pgsql",
      "sudo mkdir -p /var/lib/pgsql",
      "sudo mount /dev/alvaria/opt /opt",
      "sudo mount /dev/alvaria/var_opt /var/opt",
      "sudo mount /dev/alvaria/var_lib_pgsql /var/lib/pgsql",
      "echo '/dev/alvaria/opt /opt xfs defaults 0 0' | sudo tee -a /etc/fstab",
      "echo '/dev/alvaria/var_opt /var/opt xfs defaults 0 0' | sudo tee -a /etc/fstab",
      "echo '/dev/alvaria/var_lib_pgsql /var/lib/pgsql xfs defaults 0 0' | sudo tee -a /etc/fstab",
      "sudo lsblk",
      "sudo vgs",
      "sudo yum install net-tools wget mlocate -y",
      "sudo rm -rf /etc/yum.repos.d/*repo",
      "sudo wget https://aclalvyum.noblehosted.com/alvaria-almalinux.repo -O /etc/yum.repos.d/alvaria.repo",
      "echo 'aclalvyum.alvaria.com' | sudo tee /etc/yum/vars/patchingserver > /dev/null",
      "sudo sed -i 's/^enabled=.*/enabled=1/' /etc/yum.repos.d/alvaria.repo",
      "sudo yum clean all",
      "sudo yum install -y alvaria-cx-install",
      "sudo /opt/alvaria/alvaria-cx-install/bin/install --no-dry-run --no-harden-me --no-repo --no-ntp core/${var.host_type}",

    ]
  }

  post-processor "vagrant" {}
  post-processor "compress" {}
}
