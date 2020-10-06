variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."
  type        = string
  default     = "RG-KOS-2"
}

variable "location" {
  description = "(Optional) The location in which the resources will be created."
  type        = string
  default     = "West Europe"
}

variable "vnet" {
  type = map(any)
  default = {
    name = "VNET-KOS-2"
    addr = "10.1.0.0/16"
  }
}

variable "subnets" {
  description = "The Subnets to be created."
  type = map(list(string))
  default = {
      "frontend"  = ["10.1.1.0/27"]
      "backend"   = ["10.1.2.32/27"]
      "appGw"  = ["10.1.3.64/27"]
    }
}

variable "vm_dc" {
  description = ""
  type        = map(any)
  default     = {
    hostname  = "dc1"
    subnet    = "frontend"
    size      = "Standard_D2s_v3"
    osname    = "WindowsServer"
    osversion = "latest"
  }
}


variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure."
  type        = string
  default     = "Azerty123456!"
}
variable "admin_username" {
  description = "The admin username of the VM that will be deployed."
  type        = string
  default     = "azureuser"
}

variable "custom_data" {
  description = "The custom data to supply to the machine. This can be used as a cloud-init for Linux systems."
  type        = string
  default     = ""
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  type        = string
  default     = "Standard_LRS"
}



