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
  name                     = "storageaccount${random_string.random.result}"
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

resource "azurerm_storage_blob" "blob" {
  name                   = "appTP2.zip"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.storage_container.name
  type                   = "Block"
  source                 = "C:/Users/sarah/OneDrive/Documents/études/M2/Cloud computing/TP/Provisionnement d'une base de donnée NoSql et d'un blob de stockage/CloudComputingTp2/API Python/test/appTP2.zip"
}


data "azurerm_storage_account_sas" "sas" {
  connection_string = azurerm_storage_account.storage.primary_connection_string

  start = "2024-10-02T00:00:00Z"
  expiry = "2025-04-30T00:00:00Z" # Date d'expiration de la SAS
  
  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  resource_types {
    service   = false
    container = false
    object    = true
  }

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
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
  
  site_config {
    application_stack {
      python_version = 3.12
    }
  }
  
  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "https://${azurerm_storage_account.storage.name}.blob.core.windows.net/${azurerm_storage_container.storage_container.name}/${azurerm_storage_blob.blob.name}?${data.azurerm_storage_account_sas.sas.sas}"
    SCM_DO_BUILD_DURING_DEPLOYMENT = true
  }
}