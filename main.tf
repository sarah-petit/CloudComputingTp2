resource "random_string" "random" {
  length           = 8
  special          = false
  upper            = false
}

#Create the group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "TP2-rg"
}

#Create DB NoSQL Account
resource "azurerm_cosmosdb_account" "cosmos" {
    name = "cosmosdb-${random_string.random.result}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    offer_type = "Standard"
    kind = "GlobalDocumentDB"

    consistency_policy {
        consistency_level = "BoundedStaleness"
        max_interval_in_seconds = 300
        max_staleness_prefix = 100000
    }

    geo_location {
        location          = azurerm_resource_group.rg.location
        failover_priority = 0
    }
}

#Cosmo DB SQL Database
resource "azurerm_cosmosdb_sql_database" "sql_db" {
  name                = "sql-database-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
}

#Cosmo DB SQL Container
resource "azurerm_cosmosdb_sql_container" "sql_container" {
  name                = "sql-container-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.sql_db.name
  partition_key_paths  = ["/definition/id"]
}

#Create the Blob storage
resource "azurerm_storage_account" "storage" {
  name                     = "storage-account-${random_string.random.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "storage-container-${random_string.random.result}"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

#Create app service
resource "azurerm_service_plan" "plan" {
  name                = "plan-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "B1"
  os_type             = "Linux"
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.plan.location
  service_plan_id     = azurerm_service_plan.plan.id
  zip_deploy_file = "C:/Users/sarah/OneDrive/Documents/études/M2/Cloud computing/TP/Provisionnement d'une base de donnée NoSql et d'un blob de stockage/API Python/test/appTP2.zip"

  site_config {
  }
  
  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = 1
  }
}