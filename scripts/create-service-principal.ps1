<#
.SYNOPSIS
    Creates an Azure Service Principal for CI/CD authentication.

.DESCRIPTION
    This script creates a Service Principal with Contributor access scoped
    to a specific Resource Group. The resulting credentials can be used by
    GitHub Actions, Jenkins, or other automation tools to deploy to Azure.

.PARAMETER spName
    The name of the Service Principal to create. Default is "java-azure-deployer".

.PARAMETER resourceGroup
    The name of the Resource Group to assign permissions to. Default is "java-azure-demo-rg".

.EXAMPLE
    .\scripts\create-service-principal.ps1
    Creates a Service Principal named "java-azure-deployer" with access to "java-azure-demo-rg".

.EXAMPLE
    .\scripts\create-service-principal.ps1 -spName "myapp-deployer" -resourceGroup "myapp-rg"
    Creates a Service Principal named "myapp-deployer" with access to "myapp-rg".

.NOTES
    Author: Your Name
    Date: 2025-11-03
    Requires: Azure CLI (az)
    After running this script, copy the JSON output and save it as the
    GitHub Actions secret named AZURE_CREDENTIALS.
#>

param(
    [string]$spName = "java-azure-deployer",
    [string]$resourceGroup = "java-azure-demo-rg"
)

# Get current subscription
$subscriptionId = az account show --query id -o tsv

Write-Host "🔐 Creating Service Principal: $spName"
Write-Host "Subscription ID: $subscriptionId"
Write-Host "Resource Group: $resourceGroup"

$sp = az ad sp create-for-rbac `
  --name $spName `
  --role contributor `
  --scopes /subscriptions/$subscriptionId/resourceGroups/$resourceGroup `
  --sdk-auth

Write-Host "`n✅ Service Principal created successfully!"
Write-Host "---------------------------------------------"
Write-Host "Save the following JSON as your GitHub Secret:"
Write-Host "Secret name: AZURE_CREDENTIALS"
Write-Host $sp
Write-Host "---------------------------------------------"
