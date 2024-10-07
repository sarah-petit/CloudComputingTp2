output "cosmodb_uri" {
  value = azurerm_cosmosdb_account.cosmos.endpoint
}

output "storage_account" {
  value = azurerm_storage_account.storage.primary_blob_endpoint
}

output "app_service_url" {
    value = "${azurerm_linux_web_app.app.name}.azurewebsites.net"
}