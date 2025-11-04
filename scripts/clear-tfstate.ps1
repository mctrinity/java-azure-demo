<#
.SYNOPSIS
    Securely deletes a Terraform state (.tfstate) blob from Azure Storage.

.DESCRIPTION
    This script safely removes a Terraform state file from your Azure backend.
    Before deletion, it can optionally create a local timestamped backup
    (with the project name prefix). All console output is sanitized to redact
    sensitive data such as subscription IDs, GUIDs, access keys, and blob URLs.

.PARAMETER resourceGroup
    Azure Resource Group containing the storage account. Default: tfstate-rg

.PARAMETER storageAccount
    Azure Storage Account used by the Terraform backend. Default: orgtfstate

.PARAMETER containerName
    Blob container storing the tfstate file. Default: tfstate

.PARAMETER blobName
    Name of the Terraform state blob to delete. Default: java-azure-demo.tfstate

.PARAMETER backupBeforeDelete
    Optional switch. If set, downloads a timestamped backup of the tfstate file
    before deletion.

.EXAMPLE
    .\scripts\clear-tfstate.ps1
    Deletes the tfstate blob securely, redacting all sensitive logs.

.EXAMPLE
    .\scripts\clear-tfstate.ps1 -backupBeforeDelete
    Creates a secure backup of the tfstate file before deleting it.

.NOTES
    Author: Your Name
    Date: 2025-11-04
    Requires: Azure CLI (az)
#>

param (
    [string]$resourceGroup = "tfstate-rg",
    [string]$storageAccount = "orgtfstate",
    [string]$containerName = "tfstate",
    [string]$blobName = "java-azure-demo.tfstate",
    [switch]$backupBeforeDelete
)

# ------------------------------------------
# Helper: Securely print redacted output
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

Write-SecureOutput "⚙️  Starting secure Terraform state cleanup..."
Write-SecureOutput "Target: $storageAccount/$containerName/$blobName"
Write-SecureOutput "------------------------------------------"

# 1️⃣ Login to Azure
Write-SecureOutput "🔐 Logging in to Azure..."
$loginOutput = az login 2>&1
Write-SecureOutput ($loginOutput | Out-String)

# 2️⃣ Retrieve Storage Account Key
Write-SecureOutput "🔑 Retrieving storage account key..."
$keyOutput = az storage account keys list `
  --resource-group $resourceGroup `
  --account-name $storageAccount `
  --query "[0].value" -o tsv 2>&1

$accountKey = ($keyOutput | Out-String).Trim()
if (-not $accountKey) {
    Write-SecureOutput "❌ Failed to retrieve storage account key. Please check access."
    exit 1
}

# 3️⃣ Optional Backup Before Delete
if ($backupBeforeDelete) {
    Write-SecureOutput "💾 Backup requested — downloading blob before deletion..."
    $timestamp = Get-Date -Format "yyyy-MM-dd-HHmm"
    $backupDir = "./backups"
    if (!(Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }

    # Extract a safe prefix from blob name (strip .tfstate)
    $prefix = ($blobName -replace '\.tfstate$', '')
    $backupFile = "$backupDir/${prefix}-$timestamp.tfstate"

    $downloadOutput = az storage blob download `
      --account-name $storageAccount `
      --container-name $containerName `
      --name $blobName `
      --file $backupFile `
      --account-key $accountKey 2>&1

    Write-SecureOutput ($downloadOutput | Out-String)

    if (Test-Path $backupFile) {
        Write-SecureOutput "✅ Backup created: $backupFile"
    } else {
        Write-SecureOutput "⚠️  Backup failed or blob not found."
    }
}

# 4️⃣ Delete Blob
Write-SecureOutput "🗑️  Deleting tfstate blob..."
$deleteOutput = az storage blob delete `
  --account-name $storageAccount `
  --container-name $containerName `
  --name $blobName `
  --account-key $accountKey `
  --only-show-errors 2>&1

Write-SecureOutput ($deleteOutput | Out-String)

# 5️⃣ Verify Deletion
Write-SecureOutput "🔍 Verifying deletion..."
$exists = az storage blob exists `
  --account-name $storageAccount `
  --container-name $containerName `
  --name $blobName `
  --account-key $accountKey `
  --query "exists" -o tsv 2>&1

if ($exists -match "false") {
    Write-SecureOutput "✅ Terraform state successfully cleared."
} else {
    Write-SecureOutput "⚠️  Terraform state still exists — please verify manually."
}

Write-SecureOutput "`n🎯 Done. Terraform will rebuild state automatically on next deploy."
Write-SecureOutput "All sensitive information has been redacted from output."
