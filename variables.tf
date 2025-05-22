variable "custom_image_resource_group_name" {
  description = "Resource group where the custom image is stored"
  type        = string
  default     = "custom-image-rg"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "vmss-resources"
}

variable "location" {
  description = "The Azure Region in which to create resources"
  type        = string
  default     = "centralus"
}

variable "vm_sku" {
  description = "SKU for the VMs in the scale set"
  type        = string
  default     = "Standard_D2_v4"
}

variable "admin_username" {
  description = "Admin username for the VMs"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Admin password for the VMs"
  type        = string
  sensitive   = true
}

variable "custom_image_name" {
  description = "Name of the custom image to use for the virtual machine scale set"
  type        = string
  default     = "win2022-devops-agent-1.0.0"
}

variable "source_image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })

  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}
