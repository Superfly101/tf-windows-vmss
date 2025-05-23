# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

data "azurerm_image" "custom" {
  name                = var.custom_image_name
  resource_group_name = var.custom_image_resource_group_name
}

# No storage resources - these are created manually in Azure Portal

resource "azurerm_virtual_network" "vnet" {
  name                = "vmss-network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Optional: Add NSG rule to allow RDP access for verification
resource "azurerm_network_security_group" "vmss_nsg" {
  name                = "vmss-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*" # For production, restrict this to your IP
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.vmss_nsg.id
}

# Optional: Add public IP for RDP access
resource "azurerm_public_ip_prefix" "vmss" {
  name                = "vmss-ip-prefix"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  prefix_length       = 28
}

resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
  name                     = "windows-vmss"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = var.vm_sku
  instances                = 1
  admin_password           = var.admin_password
  admin_username           = var.admin_username
  overprovision            = false
  computer_name_prefix     = "vm"
  enable_automatic_updates = false

  source_image_id = data.azurerm_image.custom.id

  dynamic "source_image_reference" {
    for_each = data.azurerm_image.custom.id == null ? [var.source_image] : []
    content {
      publisher = var.source_image.publisher
      offer     = var.source_image.offer
      sku       = var.source_image.sku
      version   = var.source_image.version
    }
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "${azurerm_virtual_network.vnet.name}-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id

      public_ip_address {
        name                    = "vmss-public-ip"
        public_ip_prefix_id     = azurerm_public_ip_prefix.vmss.id
        idle_timeout_in_minutes = 15
      }
    }
  }

  # Custom script extension to download and execute the PowerShell script
  extension {
    name                       = "CustomScriptExtension"
    publisher                  = "Microsoft.Compute"
    type                       = "CustomScriptExtension"
    type_handler_version       = "1.10"
    auto_upgrade_minor_version = true

    settings = jsonencode({
      fileUris = [var.script_blob_url]
    })

    protected_settings = jsonencode({
      storageAccountName = var.storage_account_name
      storageAccountKey  = var.storage_account_key
      commandToExecute   = "powershell -ExecutionPolicy Unrestricted -File ${var.script_file_name} -TaskName 'DemoScheduledTask' -TaskDescription 'Demo task created via Terraform VMSS'"
    })
  }
}

# Outputs for verification
output "vmss_id" {
  value = azurerm_windows_virtual_machine_scale_set.vmss.id
}
