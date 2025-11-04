variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "java-azure-demo-rg"
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "eastus"
}

variable "app_name" {
  description = "Name of the Web App"
  type        = string
  default     = "java-azure-demo-app"
}

variable "azure_credentials" {
  description = "Azure service principal credentials in JSON format"
  type        = string
}
