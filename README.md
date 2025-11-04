# Java Azure Demo Project

This repository demonstrates how to build, provision, and deploy a simple Java application to **Microsoft Azure App Service** using **Terraform** for infrastructure-as-code and **GitHub Actions** for CI/CD.

---

## 🧱 Project Structure

```
java-azure-demo/
├── src/                   # Java source code
├── target/                # Compiled JAR output
├── infra/                 # Terraform configuration
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
├── scripts/               # PowerShell setup scripts
│   ├── create-resource-group.ps1
│   ├── create-service-principal.ps1
│   ├── create-tf-backend.ps1
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions workflow
└── pom.xml                 # Maven build configuration
```

---

## ⚙️ Prerequisites

Before you begin, ensure you have the following installed:

* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Terraform](https://developer.hashicorp.com/terraform/downloads)
* [Java 17+](https://adoptium.net/)
* [Maven](https://maven.apache.org/download.cgi)
* A GitHub account connected to an Azure Subscription

---

## 🚀 Setup Guide

### 1. Create the Azure Resource Group

Run the script below to create a resource group for the app:

```powershell
./scripts/create-resource-group.ps1 -resourceGroup "java-azure-demo-rg" -location "eastus"
```

### 2. Create the Terraform Backend

This script provisions the storage backend for Terraform state:

```powershell
./scripts/create-tf-backend.ps1
```

After running, it outputs the backend block to include in `infra/main.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "orgtfstate"
    container_name       = "tfstate"
    key                  = "java-azure-demo.tfstate"
  }
}
```

Go to the Azure Portal → your storage account → **Access keys**, and copy one (`key1` or `key2`).
Then set it as an environment variable:

```powershell
$env:ARM_ACCESS_KEY = "<your-key>"
```

---

### 3. Create the Service Principal

Run this once to create a Service Principal for GitHub Actions:

```powershell
./scripts/create-service-principal.ps1 -spName "java-azure-deployer" -resourceGroup "java-azure-demo-rg"
```

This will output a JSON block. Copy it and store it as a GitHub Secret:

| Secret Name         | Value                                |
| ------------------- | ------------------------------------ |
| `AZURE_CREDENTIALS` | (Entire JSON output from the script) |

Assign these roles to the SP:

* **Contributor** on `java-azure-demo-rg`
* **Storage Blob Data Contributor** on the Terraform storage account

---

### 4. Configure GitHub Secrets

In your GitHub repository, go to:

> **Settings → Secrets and variables → Actions → New repository secret**

Add the following:

| Secret Name         | Purpose                     |
| ------------------- | --------------------------- |
| `AZURE_CREDENTIALS` | JSON from Service Principal |
| `ARM_ACCESS_KEY`    | Storage account access key  |

---

### 5. Build and Deploy

Terraform creates your Azure App Service Plan and Web App automatically:

```powershell
cd infra
terraform init
terraform apply -auto-approve
```

Then, every push to `main` triggers the CI/CD pipeline in GitHub Actions:

* Builds the Java app with Maven
* Deploys the `.jar` to your Azure Web App

---

## ⚙️ GitHub Actions Workflow Overview

**File:** `.github/workflows/deploy.yml`

* Initializes Terraform and applies infrastructure changes
* Builds the app with Maven
* Logs in to Azure using the Service Principal
* Deploys the app to Azure App Service

Pipeline is secure — all credentials are stored as GitHub Secrets.

---

## 🧠 Troubleshooting Terraform Authentication

If you encounter the error:

```
Error: unable to build authorizer for Resource Manager API: could not configure AzureCli Authorizer
```

Terraform cannot authenticate in GitHub Actions because `az login` is not available in runners.

✅ **Fix:** Use explicit Service Principal credentials in Terraform.

1. Update `provider "azurerm"` block:

   ```hcl
   provider "azurerm" {
     features {}

     subscription_id = jsondecode(var.azure_credentials)["subscriptionId"]
     client_id       = jsondecode(var.azure_credentials)["clientId"]
     client_secret   = jsondecode(var.azure_credentials)["clientSecret"]
     tenant_id       = jsondecode(var.azure_credentials)["tenantId"]
   }
   ```

2. Add to `variables.tf`:

   ```hcl
   variable "azure_credentials" {
     description = "Azure service principal credentials in JSON format"
     type        = string
   }
   ```

3. Pass the credentials from GitHub Actions:

   ```yaml
   - name: Terraform Apply
     working-directory: infra
     run: terraform apply -auto-approve -var="azure_credentials=${{ secrets.AZURE_CREDENTIALS }}"
   ```

This ensures Terraform authenticates securely using your Service Principal JSON instead of relying on an Azure CLI login.

---

### 🔍 Test Locally Before Pushing

You can test authentication locally using the same Service Principal credentials to confirm everything works before committing to GitHub:

1. Save your JSON credentials to a file (e.g., `azure_credentials.json`).
2. Run Terraform commands locally with:

   ```powershell
   cd infra
   terraform init
   terraform plan -var="azure_credentials=$(Get-Content ../azure_credentials.json -Raw)"
   ```
3. If `terraform plan` runs successfully, your credentials and backend are configured correctly.

This mirrors what GitHub Actions does during CI/CD.

#### 🧩 Secure Storage Tip

* **Never commit your `azure_credentials.json` file to Git!**
* Add it to your `.gitignore` file:

  ```
  azure_credentials.json
  ```
* Store it securely (e.g., in an encrypted local vault or password manager).
* Use it only for local Terraform testing — GitHub Actions will use the secret instead.

---

## ✅ Verification

After deployment, Terraform outputs your Web App URL. You can also find it in Azure Portal → **App Services → java-azure-demo-app**.

Test it in a browser:

```
https://java-azure-demo-app.azurewebsites.net
```

---

## 🧠 Notes

* `terraform apply` is **idempotent** — it won’t recreate resources unless configuration changes.
* Each Terraform project should use a unique backend `key`.
* You can reuse the same `tfstate` storage account for multiple apps.
* Your Hotmail Azure account works fine — just use the storage **access key** instead of Entra ID roles.

---

## 🧹 Cleanup

To remove everything created by Terraform:

```powershell
cd infra
terraform destroy -auto-approve
```

If you also want to remove the backend storage (optional):

```powershell
az group delete --name tfstate-rg --yes --no-wait
```
