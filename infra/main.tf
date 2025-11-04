terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0"

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
# Log Analytics Workspace (required for Container Apps)
# -------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.app_name}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# -------------------------------------------------------------
# Azure Container Registry
# -------------------------------------------------------------
resource "azurerm_container_registry" "acr" {
  name                = "${replace(var.app_name, "-", "")}acr"  # ACR names can't have hyphens
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    Environment = "demo"
    Project     = "java-azure-demo"
  }
}

# -------------------------------------------------------------
# Container Apps Environment
# -------------------------------------------------------------
resource "azurerm_container_app_environment" "env" {
  name                       = "${var.app_name}-env"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  # Add tags for debugging
  tags = {
    Environment = "demo"
    Project     = "java-azure-demo"
  }
}

# -------------------------------------------------------------
# Container App (Java)
# -------------------------------------------------------------
resource "azurerm_container_app" "app" {
  name                         = var.app_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    min_replicas = 0
    max_replicas = 2

    container {
      name   = "java-app"
      # Start with a placeholder image; GitHub Actions will update this
      image  = "eclipse-temurin:17-jdk-alpine"
      cpu    = "0.25"
      memory = "0.5Gi"

      env {
        name  = "PORT"
        value = "8080"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  # Configure ACR access
  registry {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }

  # Add tags for debugging
  tags = {
    Environment = "demo"
    Project     = "java-azure-demo"
  }
}