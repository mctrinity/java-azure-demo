<#
.SYNOPSIS
    Creates a shared Azure Storage backend for storing Terraform state files.

.DESCRIPTION
    This script automates the creation of an Azure Resource Group, Storage Account, 
    and Blob Container that can be used by Terraform as a remote backend for state management.

    It uses the Azure CLI (`az`) to provision the required resources and prints 
    the Terraform backend configuration block you can copy into your Terraform project.

.PARAMETER location
    The Azure region where the backend resources will be created. Default is "eastus".

.PARAMETER resourceGroup
    The name of the resource group to create for Terraform state storage. Default is "tfstate-rg".

.PARAMETER storageAccount
    The globally unique name of the storage account. This must be unique across Azure. Default is "orgtfstate".

.PARAMETER containerName
    The name of the blob container where Terraform state files will be stored. Default is "tfstate".

.EXAMPLE
    .\scripts\create-tf-backend.ps1
    Creates a backend in "eastus" using default names (tfstate-rg / orgtfstate / tfstate).

.EXAMPLE
    .\scripts\create-tf-backend.ps1 -resourceGroup "tf-backend-rg" -storageAccount "mytfbackend" -containerName "terraformstate"
    Creates a backend with a custom resource group, storage account, and container name.

.NOTES
    Author: Your Name
    Date: 2025-11-03
    Requires: Azure CLI (az)
    Run this script only once per organization/environment.
    Each Terraform project should use a unique key in its backend block (e.g. projectname.tfstate).
#>

# ==========================================
# Azure Terraform Backend Setup Script
# ==========================================

param(
    [string]$location = "eastus",
    [string]$resourceGroup = "tfstate-rg",
    [string]$storageAccount = "orgtfstate",  # must be globally unique!
    [string]$containerName = "tfstate"
)

# ------------------------------------------
# 1. Login to Azure
# ------------------------------------------
Write-Host "🔐 Logging into Azure..."
az login

# ------------------------------------------
# 2. Create Resource Group
# ------------------------------------------
Write-Host "📦 Creating Resource Group: $resourceGroup ..."
az group create `
  --name $resourceGroup `
  --location $location

# ------------------------------------------
# 3. Create Storage Account
# ------------------------------------------
Write-Host "💾 Creating Storage Account: $storageAccount ..."
az storage account create `
  --name $storageAccount `
  --resource-group $resourceGroup `
  --location $location `
  --sku Standard_LRS `
  --encryption-services blob

# ------------------------------------------
# 4. Get Storage Account Key
# ------------------------------------------
Write-Host "🔑 Fetching Storage Account key..."
$accountKey = az storage account keys list `
  --resource-group $resourceGroup `
  --account-name $storageAccount `
  --query [0].value -o tsv

# ------------------------------------------
# 5. Create Blob Container for tfstate
# ------------------------------------------
Write-Host "📁 Creating container: $containerName ..."
az storage container create `
  --name $containerName `
  --account-name $storageAccount `
  --account-key $accountKey

# ------------------------------------------
# 6. Output Terraform backend config
# ------------------------------------------
Write-Host "`n✅ Terraform backend created successfully!"
Write-Host "---------------------------------------------"
Write-Host "Resource Group: $resourceGroup"
Write-Host "Storage Account: $storageAccount"
Write-Host "Container: $containerName"
Write-Host "Location: $location"
Write-Host "`nUse this backend block in your Terraform:"
Write-Host @"
terraform {
  backend "azurerm" {
    resource_group_name  = "$resourceGroup"
    storage_account_name = "$storageAccount"
    container_name       = "$containerName"
    key                  = "your-project-name.tfstate"
  }
}
"@
Write-Host "---------------------------------------------"
