packer {
  required_plugins {
    vsphere = {
      version = "~> 1"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

source "vsphere-iso" "windows_2022" {
  vcenter_server      = "10.30.0.30"
  username            = "administrator@normslab.com"
  password            = "Ph1shstix!"
  cluster             = "Mazinger"
  datacenter          = "Mazinger-NormsLab"
  folder              = "CX23"
  datastore           = "CX_Mazinger"
  host                = "10.30.30.110"
  insecure_connection = "true"

  vm_name              = "Win2022_Packer"
  CPUs                 = "4"
  RAM                  = "8192"
  RAM_reserve_all      = true
  communicator         = "ssh"  # Using SSH instead of WinRM
  ssh_username         = "vagrant"  # Specify the SSH username here
  ssh_password         = "vagrant"  # Specify the SSH password here
  disk_controller_type = ["lsilogic-sas"]
  firmware             = "bios"
  floppy_files         = ["setup/w2k22/autounattend.xml", "setup/vmtools.cmd"]
  guest_os_type        = "windows9Server64Guest"
  iso_paths            = ["[CX_Mazinger] ISO/SERVER_EVAL_x64FRE_en-us.iso","[CX_Mazinger] ISO/VMware-tools-windows-12.4.0-23259341.iso"]

  network_adapters {
    network      = "VM Network"
    network_card = "vmxnet3"
  }

  storage {
    disk_size             = "32768"
    disk_thin_provisioned = true
  }

  convert_to_template = "true"
}

variable "name" {
  description = "The name of the build"
  default     = "windows-server-2022"
}

variable "static_ip" {
  description = "The static IP address to assign to the Windows server"
  default     = "10.30.30.120"  # Set your desired static IP here
}

build {
  sources = ["source.vsphere-iso.windows_2022"]

  provisioner "windows-shell" {
    inline = ["dir c:\\"]
  }
}

