<#
.SYNOPSIS
    Securely lists Terraform state blobs in your Azure backend.

.DESCRIPTION
    This script lists all tfstate files stored in your Azure Storage container,
    while ensuring all output (including warnings) is redacted for security.

.PARAMETER resourceGroup
    Azure Resource Group containing the backend. Default: tfstate-rg

.PARAMETER storageAccount
    Azure Storage Account used for tfstate. Default: orgtfstate

.PARAMETER containerName
    Container holding Terraform states. Default: tfstate

.EXAMPLE
    .\scripts\check-tfstate.ps1
    Lists tfstate files securely, redacting any sensitive identifiers.

.NOTES
    Author: Your Name
    Date: 2025-11-04
    Requires: Azure CLI (az)
    Read-only operation — no resources modified.
#>

param (
    [string]$resourceGroup = "tfstate-rg",
    [string]$storageAccount = "orgtfstate",
    [string]$containerName = "tfstate"
)

# ------------------------------------------
# Helper: Securely print output (redacting secrets)
# ------------------------------------------
function Write-SecureOutput {
    param ([string]$text)
    $redacted = $text `
        -replace '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})', '[REDACTED-GUID]' `
        -replace '(?i)([A-Za-z0-9+/=]{20,})', '[REDACTED-SECRET]' `
        -replace '(?i)(https:\/\/[A-Za-z0-9.-]*\.blob\.core\.windows\.net\/[^\s]+)', '[REDACTED-BLOB-URL]' `
        -replace '(?i)(subscription[s]*/[0-9a-f-]+)', '[REDACTED-SUBSCRIPTION]' `
        -replace '(?i)(tenant[s]*/[0-9a-f-]+)', '[REDACTED-TENANT]'
    Write-Host $redacted
}

Write-SecureOutput "📦 Checking Terraform state files in Azure Storage..."
Write-SecureOutput "Target: $storageAccount/$containerName"
Write-SecureOutput "------------------------------------------"

# 1️⃣ Authenticate
Write-SecureOutput "🔐 Logging in to Azure..."
$loginOutput = az login 2>&1
Write-SecureOutput ($loginOutput | Out-String)

# 2️⃣ Retrieve Storage Key
Write-SecureOutput "🔑 Retrieving storage account key..."
$keyOutput = az storage account keys list `
  --resource-group $resourceGroup `
  --account-name $storageAccount `
  --query "[0].value" -o tsv 2>&1

$accountKey = ($keyOutput | Out-String).Trim()
if (-not $accountKey) {
    Write-SecureOutput "❌ Unable to retrieve storage key. Please check permissions."
    exit 1
}

# 3️⃣ List Blobs
Write-SecureOutput "📜 Listing .tfstate blobs..."
$listOutput = az storage blob list `
  --account-name $storageAccount `
  --container-name $containerName `
  --account-key $accountKey `
  --query "[].{Name:name, LastModified:properties.lastModified, Size:properties.contentLength}" `
  -o table 2>&1

if ($LASTEXITCODE -eq 0 -and $listOutput) {
    Write-SecureOutput "`n✅ Terraform state files found:"
    Write-SecureOutput "------------------------------------------"
    Write-SecureOutput ($listOutput | Out-String)
} else {
    Write-SecureOutput "⚠️ No Terraform state files found or unable to list blobs."
}

Write-SecureOutput "`n🎯 Done. All sensitive information redacted from output."
