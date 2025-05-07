# Azure Windows VM Scale Set Terraform Module

This Terraform module creates a Windows Virtual Machine Scale Set in Azure.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.1.0
- Azure subscription and credentials configured

## Usage

1. Clone this repository
2. Create a `terraform.tfvars` file with your credentials (this file should not be committed to git)
3. Initialize and apply the Terraform configuration

### Example terraform.tfvars

```hcl
admin_username = "yourusername"
admin_password = "YourSecurePassword123!"
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| prefix | The prefix to use for resources | string | "vmss" |
| resource_group_name | Name of the resource group | string | "vmss-resources" |
| location | The Azure Region in which to create resources | string | "eastus2" |
| vm_sku | SKU for the VMs in the scale set | string | "Standard_D2_v4" |
| instance_count | Number of VM instances | number | 1 |
| admin_username | Admin username for the VMs | string | - |
| admin_password | Admin password for the VMs | string | - |
