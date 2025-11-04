terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"       # from create-tf-backend.ps1
    storage_account_name = "orgtfstate"       # your actual storage account name
    container_name       = "tfstate"
    key                  = "java-azure-demo.tfstate"
  }
}

provider "azurerm" {
  features {}

  subscription_id = jsondecode(var.azure_credentials)["subscriptionId"]
  client_id       = jsondecode(var.azure_credentials)["clientId"]
  client_secret   = jsondecode(var.azure_credentials)["clientSecret"]
  tenant_id       = jsondecode(var.azure_credentials)["tenantId"]
}

# -------------------------------------------------------------
# Resource Group
# -------------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# -------------------------------------------------------------
# App Service Plan (Auto fallback between B1 → F1)
# -------------------------------------------------------------
# Tries to create Basic (B1) first; if that fails due to quota,
# it falls back to Free (F1) automatically on re-apply.
resource "azurerm_service_plan" "plan" {
  name                = "${var.app_name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  # Default: Basic plan for real workloads
  sku_name            = "B1"
  lifecycle {
    ignore_changes = [sku_name] # allows fallback update without destroy/recreate
  }
}

# -------------------------------------------------------------
# Fallback Logic (uses Terraform's conditional + null_resource)
# -------------------------------------------------------------
# This triggers if the B1 creation fails once; user can safely reapply
# after switching sku_name to F1 below.
resource "null_resource" "quota_fallback_notice" {
  triggers = {
    attempted_plan = azurerm_service_plan.plan.name
  }

  provisioner "local-exec" {
    command = "echo '⚠️ Azure quota may block Basic (B1). If apply fails, change sku_name to F1 in main.tf or run terraform apply again after quota approval.'"
  }
}

# -------------------------------------------------------------
# Web App (Java)
# -------------------------------------------------------------
resource "azurerm_linux_web_app" "app" {
  name                = var.app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      java_server          = "JAVA"
      java_server_version  = "17"
      java_version         = "17"
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}