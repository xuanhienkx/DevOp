terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      #version = ">= x.y.z"
    }
  }
  #required_version = ">= 0.13"
}

provider "vsphere" {
  user                 = var.vCenter_user
  password             = var.vCenter_password
  vsphere_server       = var.vCenter_server
  allow_unverified_ssl = true
}