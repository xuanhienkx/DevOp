variable "datacenter" {
  description = "Virtual Datacenter name where VM will be placed"
  type        = string
  default     = ""
}

variable "cluster" { 
  type        = string
  default     = "DAS"
}

variable "network" { 
  type        = string
  default     = ""
}

variable "datastore" { 
  type        = string
  default     = ""
}

variable "template" { 
  type        = string
  default     = "Template-Ubuntu Server20.04"
}
variable "password" {
    type        = string
    description = "Root account password"
    default     = ""
}
variable "user" {
    type        = string
    description = "Root account"
    default     = ""
}
variable "vm_ip" {
    type        = string
    description = "Root account password"
    default     = ""
}
variable "file" {
    description = "rpm for software install"
    default = "redmine.sh"
}
variable "vminfo" {
  type = map(object({
    vm     = string
    cpu    = string
    memory = string
  }))
  default = { 
    "prod" = {
      vm     = "TestCloneVMFromTemp"
      cpu    = "1"
      memory = "4096"
    }, 
  }
}