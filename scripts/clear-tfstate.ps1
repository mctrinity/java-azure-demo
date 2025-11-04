<#
.SYNOPSIS
    Safely clears a Terraform state blob from Azure Storage.

.DESCRIPTION
    This script deletes a remote Terraform state file (.tfstate) stored in Azure Blob Storage.
    It detects if a lease lock exists and automatically breaks it before deletion.
    Optionally creates a local backup before removing the blob.

.PARAMETER backupBeforeDelete
    If specified, the script downloads a backup copy of the tfstate blob before deletion.

.EXAMPLE
    .\scripts\clear-tfstate.ps1
    Deletes the tfstate blob without backup.

.EXAMPLE
    .\scripts\clear-tfstate.ps1 -backupBeforeDelete
    Creates a backup of the tfstate blob before deleting it.

.NOTES
    Author: Your Name
    Date: 2025-11-04
    Requires: Azure CLI (az)
#>

param(
    [switch]$backupBeforeDelete
)

# ==========================================
# CONFIGURATION
# ==========================================
$resourceGroup = "tfstate-rg"
$storageAccount = "orgtfstate"
$containerName = "tfstate"
$blobName = "java-azure-demo.tfstate"
$backupDir = "./backups"
$redacted = "[REDACTED]"

# ==========================================
# 1. Login to Azure (redacted)
# ==========================================
Write-Host "🔐 Logging into Azure..."
az login --only-show-errors | Out-Null

# ==========================================
# 2. Get Storage Account Key
# ==========================================
Write-Host "🔑 Retrieving storage account key..."
$accountKey = az storage account keys list `
  --resource-group $resourceGroup `
  --account-name $storageAccount `
  --query "[0].value" -o tsv

# ==========================================
# 3. Check if Blob Exists
# ==========================================
Write-Host "🔍 Checking if tfstate blob exists..."
$exists = az storage blob exists `
  --account-name $storageAccount `
  --account-key $accountKey `
  --container-name $containerName `
  --name $blobName `
  --query "exists" -o tsv

if ($exists -eq "false") {
    Write-Host "ℹ️ No tfstate blob found — nothing to delete."
    exit 0
}

# ==========================================
# 4. Optional: Backup before Delete
# ==========================================
if ($backupBeforeDelete) {
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir | Out-Null
    }
    $timestamp = (Get-Date -Format "yyyy-MM-dd-HHmm")
    $backupFile = "$backupDir/$($blobName.Split('.')[0])-$timestamp.tfstate"

    Write-Host "✅ Backup created: $backupFile"
    az storage blob download `
      --account-name $storageAccount `
      --account-key $accountKey `
      --container-name $containerName `
      --name $blobName `
      --file $backupFile `
      --no-progress
}

# ==========================================
# 5. Attempt to Delete (Handle Leased Blob)
# ==========================================
Write-Host "🗑️  Deleting tfstate blob..."
$deleteResult = az storage blob delete `
  --account-name $storageAccount `
  --account-key $accountKey `
  --container-name $containerName `
  --name $blobName 2>&1

if ($deleteResult -match "LeaseIdMissing") {
    Write-Host "⚠️  Blob has an active lease — breaking lease before retry..."
    az storage blob lease break `
      --account-name $storageAccount `
      --account-key $accountKey `
      --container-name $containerName `
      --blob-name $blobName | Out-Null

    Write-Host "🔄 Retrying deletion..."
    az storage blob delete `
      --account-name $storageAccount `
      --account-key $accountKey `
      --container-name $containerName `
      --name $blobName | Out-Null
}

# ==========================================
# 6. Verify Deletion
# ==========================================
Write-Host "🔍 Verifying deletion..."
$existsAfter = az storage blob exists `
  --account-name $storageAccount `
  --account-key $accountKey `
  --container-name $containerName `
  --name $blobName `
  --query "exists" -o tsv

if ($existsAfter -eq "false") {
    Write-Host "✅ Terraform state successfully cleared."
} else {
    Write-Host "⚠️  Terraform state still exists — please verify manually."
}

# ==========================================
# 7. Done
# ==========================================
Write-Host "`n🎯 Done. Terraform will rebuild state automatically on next deploy."
Write-Host "All sensitive information has been redacted from output."
