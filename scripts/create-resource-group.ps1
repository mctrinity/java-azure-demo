<#
.SYNOPSIS
    Creates an Azure Resource Group.

.DESCRIPTION
    This script uses the Azure CLI to create a new Azure Resource Group.
    You can specify the resource group name and Azure region as parameters.

.PARAMETER resourceGroup
    The name of the resource group to create. Default is "java-azure-demo-rg".

.PARAMETER location
    The Azure region where the resource group will be created. Default is "eastus".

.EXAMPLE
    .\scripts\create-resource-group.ps1
    Creates a resource group named "java-azure-demo-rg" in "eastus".

.EXAMPLE
    .\scripts\create-resource-group.ps1 -resourceGroup "myapp-rg" -location "westeurope"
    Creates a resource group named "myapp-rg" in the "westeurope" region.

.NOTES
    Author: Your Name
    Date: 2025-11-03
    Requires: Azure CLI (az)
#>

param(
    [string]$resourceGroup = "java-azure-demo-rg",
    [string]$location = "eastus"
)

Write-Host "🔐 Logging into Azure..."
az login

Write-Host "📦 Creating Resource Group: $resourceGroup ..."
az group create `
  --name $resourceGroup `
  --location $location `
  --output table

Write-Host "`n✅ Resource group created successfully!"
Write-Host "--------------------------------------"
Write-Host "Resource Group: $resourceGroup"
Write-Host "Location: $location"
Write-Host "--------------------------------------"
