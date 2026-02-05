
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# The Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Resource group
resource "azurerm_resource_group" "dev-rg" {
  name     = "northdev"
  location = "North Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "northdev-vnet" {
  name                = "vnet1"
  resource_group_name = azurerm_resource_group.dev-rg.name
  location            = azurerm_resource_group.dev-rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "northdev-subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.dev-rg.name
  virtual_network_name = azurerm_virtual_network.northdev-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet" "northdev-subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.dev-rg.name
  virtual_network_name = azurerm_virtual_network.northdev-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "northdev-nsg" {
  name                = "nsg"
  location            = azurerm_resource_group.dev-rg.location
  resource_group_name = azurerm_resource_group.dev-rg.name

}

resource "azurerm_network_security_rule" "northdev-nsg-ssh" {

  resource_group_name         = azurerm_resource_group.dev-rg.name
  network_security_group_name = azurerm_network_security_group.northdev-nsg.name
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "northdev-nsg-rdp" {

  resource_group_name         = azurerm_resource_group.dev-rg.name
  network_security_group_name = azurerm_network_security_group.northdev-nsg.name
  name                        = "Allow-RDP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_subnet_network_security_group_association" "northdev-nsg-association" {
  subnet_id                 = azurerm_subnet.northdev-subnet1.id
  network_security_group_id = azurerm_network_security_group.northdev-nsg.id
}


# create a public IP address for the VM1
resource "azurerm_public_ip" "northdev-pip1" {
  name                = "pip1"
  location            = azurerm_resource_group.dev-rg.location
  resource_group_name = azurerm_resource_group.dev-rg.name
  allocation_method   = "Static"
}

# create a network interface for the VM1
resource "azurerm_network_interface" "northdev-nic1" {
  name                = "nic1"
  location            = azurerm_resource_group.dev-rg.location
  resource_group_name = azurerm_resource_group.dev-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.northdev-subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.northdev-pip1.id
  }
}


# create a linux virtual machine
resource "azurerm_linux_virtual_machine" "northdev-vm1" {
  name                = "vm1"
  resource_group_name = azurerm_resource_group.dev-rg.name
  location            = azurerm_resource_group.dev-rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.northdev-nic1.id,
  ]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/orinaazurekey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
}


