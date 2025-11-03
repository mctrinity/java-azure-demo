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

## ✅ Verification

After deployment, Terraform outputs your Web App URL. You can also find it in Azure Portal → **App Services → java-azure-demo-app**.

Test it in a browser:

```
https://java-azure-demo-app.azurewebsites.net
```

---

## 🧠 Notes

* `terraform apply` is **idempotent** — it won’t recreate resources unless you change configuration.
* Each Terraform project should use a unique `key` in the backend (`.tfstate` file).
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
