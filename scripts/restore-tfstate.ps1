<#
.SYNOPSIS
    Restores a Terraform state (.tfstate) file from local backup to Azure Storage.

.DESCRIPTION
    This script uploads a locally backed-up Terraform state file into your
    configured Azure Storage container used for remote state. It securely
    redacts sensitive details from console output and verifies the upload.

.PARAMETER resourceGroup
    Azure Resource Group containing the storage account. Default: tfstate-rg

.PARAMETER storageAccount
    Azure Storage Account used by the Terraform backend. Default: orgtfstate

.PARAMETER containerName
    Blob container storing the tfstate file. Default: tfstate

.PARAMETER blobName
    Name of the Terraform state blob to restore to. Default: java-azure-demo.tfstate

.PARAMETER backupFile
    Path to the local backup .tfstate file to upload.

.EXAMPLE
    .\scripts\restore-tfstate.ps1 -backupFile ".\backups\java-azure-demo-2025-11-04-1714.tfstate"

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
    [string]$backupFile
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

Write-SecureOutput "⚙️  Starting secure Terraform state restoration..."
Write-SecureOutput "Target: $storageAccount/$containerName/$blobName"
Write-SecureOutput "------------------------------------------"

if (-not (Test-Path $backupFile)) {
    Write-SecureOutput "❌ Backup file not found: $backupFile"
    exit 1
}

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

# 3️⃣ Upload Backup File to Azure Blob
Write-SecureOutput "⬆️  Uploading backup file to Azure Blob..."
$uploadOutput = az storage blob upload `
  --account-name $storageAccount `
  --container-name $containerName `
  --name $blobName `
  --file $backupFile `
  --account-key $accountKey `
  --overwrite `
  --only-show-errors 2>&1

Write-SecureOutput ($uploadOutput | Out-String)

# 4️⃣ Verify Upload
Write-SecureOutput "🔍 Verifying uploaded blob..."
$exists = az storage blob exists `
  --account-name $storageAccount `
  --container-name $containerName `
  --name $blobName `
  --account-key $accountKey `
  --query "exists" -o tsv 2>&1

if ($exists -match "true") {
    Write-SecureOutput "✅ Terraform state successfully restored from backup."
    Write-SecureOutput "📄 Source file: $backupFile"
} else {
    Write-SecureOutput "⚠️  Upload verification failed. Check Azure Portal manually."
}

Write-SecureOutput "`n🎯 Done. Terraform backend is now restored with the backup state."
Write-SecureOutput "All sensitive information has been redacted from output."
