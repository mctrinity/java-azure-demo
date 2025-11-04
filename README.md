# Java Azure Demo Project

This repository demonstrates how to build, provision, and deploy a simple Java application to **Microsoft Azure App Service** using **Terraform** for infrastructure-as-code and **GitHub Actions** for CI/CD.

---

## 🧱 Project Structure

```
java-azure-demo/
├── src/
├── target/
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
├── scripts/
│   ├── create-resource-group.ps1
│   ├── create-service-principal.ps1
│   ├── create-tf-backend.ps1
├── .github/
│   └── workflows/
│       └── deploy.yml
└── pom.xml
```

---

## ⚙️ Prerequisites

* Azure CLI
* Terraform
* Java 17+
* Maven
* GitHub account connected to Azure Subscription

---

## 🚀 Setup Guide

### Create Resource Group

```powershell
./scripts/create-resource-group.ps1 -resourceGroup "java-azure-demo-rg" -location "eastus"
```

### Create Terraform Backend

```powershell
./scripts/create-tf-backend.ps1
```

Use the generated backend config in `infra/main.tf`.  Set access key:

```powershell
$env:ARM_ACCESS_KEY = "<your-key>"
```

### Create Service Principal

```powershell
./scripts/create-service-principal.ps1 -spName "java-azure-deployer" -resourceGroup "java-azure-demo-rg"
```

Store the JSON output in your GitHub Secret as `AZURE_CREDENTIALS`.

---

## 🧠 Troubleshooting Terraform Authentication

If you get `az login` errors, define provider auth explicitly using Service Principal JSON, mark it as sensitive, and pass via GitHub Secrets.

### Local Testing

```powershell
cd infra
terraform init
terraform plan -var="azure_credentials=$(Get-Content ../azure_credentials.json -Raw)"
```

Never commit your local credentials file. Add it to `.gitignore`.

---

## 🧹 Cleanup

To remove everything created by Terraform:

```powershell
cd infra
terraform destroy -auto-approve
```

To remove backend storage:

```powershell
az group delete --name tfstate-rg --yes --no-wait
```

---

### 🧹 Managing GitHub Actions Logs Securely (PowerShell)

Sometimes early workflow runs may accidentally include sensitive information (like Azure credentials in logs). You can safely delete those old runs using the **GitHub CLI**.

#### 🧩 Step 1 — Check if GitHub CLI is Installed

```powershell
gh --version
```

If you see a version number, you’re good to go. If not, install it using **winget**:

```powershell
winget install --id GitHub.cli
```

Or download manually from:
👉 [https://cli.github.com/](https://cli.github.com/)

#### 🔐 Step 2 — Authenticate GitHub CLI

```powershell
gh auth login
```

Follow prompts:

1. Choose **GitHub.com**
2. Choose **HTTPS**
3. Authenticate via **web browser**
4. Confirmation:

   ```
   ✓ Logged in as <your-username>
   ```

Check status:

```powershell
gh auth status
```

#### 🧹 Step 3 — Delete Old Workflow Runs

List recent runs:

```powershell
gh run list --limit 10
```

Delete by ID:

```powershell
gh run delete <run-id> --confirm
```

Bulk-delete all runs for this workflow:

```powershell
gh run list --workflow "Deploy Java App to Azure with Terraform" --limit 100 |
ForEach-Object { $_.Split(' ')[0] } |
ForEach-Object { gh run delete $_ --confirm }
```

> ⚠️ **Note:** This is permanent and cannot be undone.
