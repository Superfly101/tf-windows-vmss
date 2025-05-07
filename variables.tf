variable "prefix" {
  description = "The prefix to use for resources"
  type        = string
  default     = "vmss"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "vmss-resources"
}

variable "location" {
  description = "The Azure Region in which to create resources"
  type        = string
  default     = "eastus2"
}

variable "vm_sku" {
  description = "SKU for the VMs in the scale set"
  type        = string
  default     = "Standard_D2_v4"
}

variable "instance_count" {
  description = "Number of VM instances"
  type        = number
  default     = 1
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
