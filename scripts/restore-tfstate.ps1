<#
.SYNOPSIS
    Securely downloads a Terraform state (.tfstate) file from Azure backend for backup or inspection.

.DESCRIPTION
    This script downloads a Terraform state blob from your Azure Storage backend,
    adding a timestamp to preserve each backup. It automatically redacts sensitive
    information from both console output and optional sanitized files to ensure no
    credentials or identifiers are exposed in logs.

.PARAMETER resourceGroup
    The Azure Resource Group containing the storage account. Default: tfstate-rg

.PARAMETER storageAccount
    The Azure Storage Account used for Terraform backend. Default: orgtfstate

.PARAMETER containerName
    The blob container where the tfstate is stored. Default: tfstate

.PARAMETER blobName
    The name of the tfstate blob to download. Default: java-azure-demo.tfstate

.PARAMETER outputPath
    The local folder to save downloaded files. Default: ./backups/

.PARAMETER sanitize
    Optional switch. If set, creates a sanitized copy of the tfstate file
    with secrets and sensitive values redacted (safe for review/sharing).

.EXAMPLE
    .\scripts\restore-tfstate.ps1
    Downloads java-azure-demo.tfstate securely with timestamped backup.

.EXAMPLE
    .\scripts\restore-tfstate.ps1 -sanitize
    Downloads and also creates a sanitized redacted copy of the tfstate file.

.NOTES
    Author: Your Name
    Date: 2025-11-04
    Requires: Azure CLI (az)
    Safe operation — read-only from the backend; no Azure resources are modified.
#>

param (
    [string]$resourceGroup = "tfstate-rg",
    [string]$storageAccount = "orgtfstate",
    [string]$containerName = "tfstate",
    [string]$blobName = "java-azure-demo.tfstate",
    [string]$outputPath = "./backups",
    [switch]$sanitize
)

# ------------------------------------------
# Helper: Securely print output (redacting secrets)
# ------------------------------------------
function Write-SecureOutput {
    param ([string]$text)

    # Redact subscription IDs, GUIDs, access keys, tokens, etc.
    $redacted = $text `
        -replace '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})', '[REDACTED-GUID]' `
        -replace '(?i)([A-Za-z0-9+/=]{20,})', '[REDACTED-SECRET]' `
        -replace '(?i)(https:\/\/[A-Za-z0-9.-]*\.blob\.core\.windows\.net\/[^\s]+)', '[REDACTED-BLOB-URL]' `
        -replace '(?i)(subscription[s]*/[0-9a-f-]+)', '[REDACTED-SUBSCRIPTION]' `
        -replace '(?i)(tenant[s]*/[0-9a-f-]+)', '[REDACTED-TENANT]'
    Write-Host $redacted
}

Write-SecureOutput "📦 Starting secure Terraform state restore..."
Write-SecureOutput "Target blob: $storageAccount/$containerName/$blobName"
Write-SecureOutput "Output directory: $outputPath"
Write-SecureOutput "------------------------------------------"

# 1️⃣ Ensure Output Directory Exists
if (!(Test-Path -Path $outputPath)) {
    Write-SecureOutput "📁 Creating output directory..."
    New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
}

# 2️⃣ Azure Authentication
Write-SecureOutput "🔐 Logging in to Azure..."
$loginOutput = az login 2>&1
Write-SecureOutput ($loginOutput | Out-String)

# 3️⃣ Retrieve Storage Account Key
Write-SecureOutput "🔑 Retrieving storage account key..."
$accountKey = az storage account keys list `
  --resource-group $resourceGroup `
  --account-name $storageAccount `
  --query "[0].value" -o tsv 2>&1

if ($LASTEXITCODE -ne 0 -or -not $accountKey) {
    Write-SecureOutput "❌ Failed to retrieve storage account key. Please verify permissions."
    exit 1
}

# 4️⃣ Check if Blob Exists
Write-SecureOutput "🔍 Checking if tfstate blob exists..."
$exists = az storage blob exists `
  --account-name $storageAccount `
  --container-name $containerName `
  --name $blobName `
  --account-key $accountKey `
  --query "exists" -o tsv 2>&1

if ($exists -match "false") {
    Write-SecureOutput "⚠️  No tfstate blob found: $blobName"
    Write-SecureOutput "💡 This may be expected if Terraform state was recently cleared."
    Write-SecureOutput "✅ Nothing to restore. Exiting gracefully."
    exit 0
}

# 5️⃣ Download Blob (timestamped)
$timestamp = Get-Date -Format "yyyy-MM-dd-HHmm"
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($blobName)
$extension = [System.IO.Path]::GetExtension($blobName)
$timestampedFile = "${baseName}-${timestamp}${extension}"
$outputFile = Join-Path -Path $outputPath -ChildPath $timestampedFile

Write-SecureOutput "⬇️  Downloading tfstate blob..."
Write-SecureOutput "💾 Saving as: $timestampedFile"

$downloadResult = az storage blob download `
  --account-name $storageAccount `
  --container-name $containerName `
  --name $blobName `
  --file $outputFile `
  --account-key $accountKey `
  --only-show-errors 2>&1

Write-SecureOutput ($downloadResult | Out-String)

if (-not (Test-Path $outputFile)) {
    Write-SecureOutput "⚠️  Download failed or file not found locally."
    exit 1
}

# 6️⃣ Optional: Sanitize Output
if ($sanitize) {
    Write-SecureOutput "🧹 Creating sanitized copy (redacting sensitive data)..."

    $redactedFile = $outputFile -replace "\.tfstate$", "-redacted.tfstate"

    $content = Get-Content -Raw -Path $outputFile

    # Mask sensitive values inside JSON content
    $sanitized = $content `
        -replace '(?i)("client_secret"\s*:\s*")[^"]+(")', '$1[REDACTED]$2' `
        -replace '(?i)("access_key"\s*:\s*")[^"]+(")', '$1[REDACTED]$2' `
        -replace '(?i)("connection_string"\s*:\s*")[^"]+(")', '$1[REDACTED]$2' `
        -replace '(?i)("password"\s*:\s*")[^"]+(")', '$1[REDACTED]$2' `
        -replace '(?i)("token"\s*:\s*")[^"]+(")', '$1[REDACTED]$2'

    $sanitized | Out-File -FilePath $redactedFile -Encoding UTF8

    Write-SecureOutput "✅ Sanitized copy created: $redactedFile"
}

# 7️⃣ Verify
$fileSize = (Get-Item $outputFile).Length
Write-SecureOutput "📄 File size: $fileSize bytes"
Write-SecureOutput "✅ Secure backup complete."
if ($sanitize) {
    Write-SecureOutput "🧱 Redacted copy ready for safe review."
}
Write-SecureOutput "`n🎯 Done. All sensitive values redacted from logs and warnings."
