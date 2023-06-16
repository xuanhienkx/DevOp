data "vsphere_datacenter" "datacenter" {
  name = var.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_resource_pool" "default" {
  name          = format("%s%s", data.vsphere_compute_cluster.cluster.name, "/Resources")
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# data "vsphere_host" "host" {
#   name          = "esxi-01.example.com"
#   datacenter_id = data.vsphere_datacenter.datacenter.id
# }
data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {
  for_each         = var.vminfo
  name             = each.value["vm"]
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = each.value["cpu"]
  memory           = each.value["memory"]
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label            = "${each.value["vm"]}-disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned  
  } 
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = each.value["vm"]
        domain    = "ckda.com.vn"
      }
      network_interface {
        ipv4_address = "${var.vm_ip}"
        ipv4_netmask = 24
      }
      ipv4_gateway = "10.10.68.254"
    }
  }
  connection {
    type = "ssh"
    host = "${var.vm_ip}"
    user = var.user
    password = "${var.password}"
    port = "22"
    agent = false
  }

  provisioner "file" {
      source      = "./${var.file}"
      destination = "/tmp/${var.file}"
  }

#  provisioner "local-exec" {
#     command = "sshpass -p ${var.guest_ssh_password} ssh-copy-id -i ${var.guest_ssh_key_public} -o StrictHostKeyChecking=no ${var.guest_ssh_user}@${self.guest_ip_addresses[0]}"
#   }
  # executes the following commands remotely
  provisioner "remote-exec" {
    inline = [
      "echo Install Appche Redmine",  
      "echo \"${var.password}\" | sudo -S chmod +x /tmp/${var.file}",  
      "echo \"${var.password}\" | sudo -S /tmp/${var.file}",
    ] 
     
    connection {
      type     = "ssh"
      agent    = false
      insecure = true   
      port = "22" 
      user     = var.user
      password = var.password
      host     = self.default_ip_address 
    }
  }
  
}  