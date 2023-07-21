packer {
  required_plugins {
    vsphere = {
      version = ">= 1.0.1"
      source = "github.com/hashicorp/vsphere"
    }
  }
}

variable "vsphere_password" {
## PKR_VAR_VSPHERE_PASSWORD
  default = env("VSPHERE_PASSWORD")
}
variable "home_dir" {
  default = env("HOME")
}

source "vsphere-iso" "ubuntu-server" {
  vcenter_server = "vcenter.mcintosh.farm"
  username = "administrator@vcenter.mcintosh.farm"
  password = var.vsphere_password
  insecure_connection   = "true"

  boot_order = "cdrom,disk"
  cd_content = {
        "meta-data" = file("meta-data")
        "user-data" = file("user-data")
  }
  cd_label = "cidata"

  datacenter = "Farm"
  datastore = "datastore1"
  folder = "templates"
  host = "dl380.mcintosh.farm"
  iso_paths = [ "[datastore1] ISO/ubuntu-22.04.2-live-server-amd64.iso" ]
##https://developer.vmware.com/apis/358/vsphere/doc/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html
  guest_os_type = "ubuntu64Guest"
##https://kb.vmware.com/s/article/1003746
  vm_version = 19
  communicator = "ssh"
  ssh_username = "ubuntu"
  ssh_password = "packer-builder"
  ssh_timeout = "30m"
  ssh_clear_authorized_keys = true
  ssh_pty = false
  ssh_private_key_file = "${var.home_dir}/.ssh/id_rsa"

  boot_wait = "3s"
  boot_command = [
    "e<down><down><down><end>",
    " autoinstall ds=nocloud;",
    "<F10>",
  ]

  RAM = 2048
  RAM_reserve_all       = true
  CPUs = 4
  storage {
    disk_size             = 8000
    disk_thin_provisioned = true
  }
  disk_controller_type  = ["pvscsi"]
  network_adapters {
    network_card        = "vmxnet3"
  }
  configuration_parameters = {
    "disk.EnableUUID" = "true"
  }
  vm_name = "ubuntu-2022-04"
  convert_to_template   = "true"

}

build {
  sources = ["source.vsphere-iso.ubuntu-server"]

  provisioner "shell" {
    execute_command = "sudo -S -E bash '{{.Path}}'"

    scripts = ["cleanup.sh"]
    expect_disconnect = true
  }
}
