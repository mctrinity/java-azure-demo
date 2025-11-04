output "container_app_name" {
  description = "Name of the Container App"
  value       = azurerm_container_app.app.name
}

output "container_app_url" {
  description = "URL of the Container App"
  value       = "https://${azurerm_container_app.app.latest_revision_fqdn}"
}

output "container_app_fqdn" {
  description = "FQDN of the Container App"
  value       = azurerm_container_app.app.latest_revision_fqdn
}

# Keep these for backward compatibility during transition
output "webapp_name" {
  description = "Name of the app (Container App)"
  value       = azurerm_container_app.app.name
}

output "webapp_url" {
  description = "URL of the app (Container App)" 
  value       = azurerm_container_app.app.latest_revision_fqdn
}
