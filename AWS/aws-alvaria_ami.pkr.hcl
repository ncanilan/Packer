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
    volume_size           = 40
    volume_type           = "gp2"
    delete_on_termination = true
  }
  // Notice that instead of providing a list of mappings, you are just providing
  // multiple mappings in a row. This diverges from the JSON template format.
  ami_block_device_mappings {
    device_name  = "/dev/sdb"
    virtual_name = "ephemeral0"
  }
  ami_block_device_mappings {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral1"
  }
}

build {
  name   = "alvaria-core-basic"
  sources = ["source.amazon-ebs.alvaria-alma9"]

  provisioner "shell" {
    inline = [
      "sudo yum install -y cloud-utils-growpart lvm2",
      "sudo lsblk",
      "sudo vgs",
      "sudo yum install net-tools wget mlocate -y",
      "sudo rm -rf /etc/yum.repos.d/*repo",
      "sudo wget https://aclalvyum.noblehosted.com/alvaria-almalinux.repo -O /etc/yum.repos.d/alvaria.repo",
      "echo 'aclalvyum.alvaria.com' | sudo tee /etc/yum/vars/patchingserver > /dev/null",
      "sudo sed -i 's/^enabled=.*/enabled=1/' /etc/yum.repos.d/alvaria.repo",
      "sudo yum install -y alvaria-cx-install",
      "sudo /opt/alvaria/alvaria-cx-install/bin/install --no-dry-run --no-harden-me --no-ntp core/siphony",
    ]
  }

  post-processor "vagrant" {}
  post-processor "compress" {}
}

