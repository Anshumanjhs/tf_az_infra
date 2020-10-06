# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = ">2.20.0"
  features {}
}

# Needed to convert simple name to detailed attributes
module "os" {
  source       = "./os"
  vm_os_simple = var.vm_dc.osname
}

# Provision Resource Group
resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location
}

# Create VNet
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet.name
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = [var.vnet.addr]
}

# Create Subnets
resource "azurerm_subnet" "subnet" {
  for_each            = var.subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value
}

resource "azurerm_virtual_machine" "dc" {
  name                          = var.vm_dc.hostname
  resource_group_name           = azurerm_resource_group.lab.name
  location                      = coalesce(var.location, azurerm_resource_group.lab.location)
  vm_size                       = var.vm_dc.size
  network_interface_ids         = [azurerm_network_interface.vm_dc.id]
  delete_os_disk_on_termination = true

  storage_image_reference {
    id        = ""
    publisher = module.os.calculated_value_os_publisher
    offer     = module.os.calculated_value_os_offer
    sku       = module.os.calculated_value_os_sku
    version   = var.vm_dc.osversion
  }

  storage_os_disk {
    name              = "${var.vm_dc.hostname}-osdisk"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = var.storage_account_type
  }

  os_profile {
    computer_name  = var.vm_dc.hostname
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }

}

resource "azurerm_public_ip" "vm_dc" {
  name                = "${var.vm_dc.hostname}-pip"
  resource_group_name = azurerm_resource_group.lab.name
  location            = coalesce(var.location, azurerm_resource_group.lab.location)
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "vm_dc" {
  name                          = "${var.vm_dc.hostname}-nic"
  resource_group_name           = azurerm_resource_group.lab.name
  location                      = coalesce(var.location, azurerm_resource_group.lab.location)
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "${var.vm_dc.hostname}-ip"
    subnet_id                     = azurerm_subnet.subnet[var.vm_dc.subnet].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_dc.id
  }

}
