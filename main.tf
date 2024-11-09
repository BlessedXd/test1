terraform {
  required_version = ">=1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "valeriy777_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "valeriy777_vnet" {
  name                = "valeriy777-vnet"
  location            = azurerm_resource_group.valeriy777_rg.location
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "valeriy777_app_subnet" {
  name                 = "valeriy777-app-subnet"
  resource_group_name  = azurerm_resource_group.valeriy777_rg.name
  virtual_network_name = azurerm_virtual_network.valeriy777_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }

  service_endpoints = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "valeriy777_private_endpoint_subnet" {
  name                 = "valeriy777-private-endpoint-subnet"
  resource_group_name  = azurerm_resource_group.valeriy777_rg.name
  virtual_network_name = azurerm_virtual_network.valeriy777_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_app_service_plan" "valeriy777_plan" {
  name                = "valeriy777-app-plan"
  location            = azurerm_resource_group.valeriy777_rg.location
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "valeriy777_app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.valeriy777_rg.location
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  app_service_plan_id = azurerm_app_service_plan.valeriy777_plan.id
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "valeriy777_app_vnet_integration" {
  app_service_id = azurerm_app_service.valeriy777_app.id
  subnet_id      = azurerm_subnet.valeriy777_app_subnet.id
}

resource "azurerm_application_insights" "valeriy777_ai" {
  name                = "valeriy777-app-insights"
  location            = azurerm_resource_group.valeriy777_rg.location
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  application_type    = "web"
}

resource "azurerm_container_registry" "valeriy777_acr" {
  name                = "valeriy777acr"
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  location            = azurerm_resource_group.valeriy777_rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_key_vault" "valeriy777_kv" {
  name                = "valeriy777-kv"
  location            = azurerm_resource_group.valeriy777_rg.location
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  tenant_id           = var.tenant_id
  sku_name            = "standard"
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [azurerm_subnet.valeriy777_app_subnet.id]
  }
}

resource "azurerm_role_assignment" "app_service_acr_access" {
  scope                = azurerm_container_registry.valeriy777_acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_app_service.valeriy777_app.identity[0].principal_id
}

resource "azurerm_key_vault_access_policy" "valeriy777_kv_policy" {
  key_vault_id = azurerm_key_vault.valeriy777_kv.id
  tenant_id    = var.tenant_id
  object_id    = azurerm_app_service.valeriy777_app.identity[0].principal_id

  secret_permissions      = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
}

resource "azurerm_sql_server" "valeriy777_sql" {
  name                         = "tfvaleriy777sqlserver"
  resource_group_name          = azurerm_resource_group.valeriy777_rg.name
  location                     = azurerm_resource_group.valeriy777_rg.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
}

resource "azurerm_sql_database" "valeriy777_sql_db" {
  name                = "valeriy777db"
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  location            = azurerm_resource_group.valeriy777_rg.location
  server_name         = azurerm_sql_server.valeriy777_sql.name
}

resource "azurerm_private_endpoint" "valeriy777_sql_private_endpoint" {
  name                = "valeriy777-sql-private-endpoint"
  location            = azurerm_resource_group.valeriy777_rg.location
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  subnet_id           = azurerm_subnet.valeriy777_private_endpoint_subnet.id

  private_service_connection {
    name                           = "sqlPrivateEndpointConnection"
    private_connection_resource_id = azurerm_sql_server.valeriy777_sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "valeriy777_sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "valeriy777_sql_dns_vnet_link" {
  name                  = "valeriy777-sql-vnet-link"
  resource_group_name   = azurerm_resource_group.valeriy777_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.valeriy777_sql_dns.name
  virtual_network_id    = azurerm_virtual_network.valeriy777_vnet.id
}

resource "azurerm_storage_account" "valeriy777_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.valeriy777_rg.name
  location                 = azurerm_resource_group.valeriy777_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_private_endpoint" "valeriy777_storage_private_endpoint" {
  name                = "valeriy777-storage-private-endpoint"
  location            = azurerm_resource_group.valeriy777_rg.location
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  subnet_id           = azurerm_subnet.valeriy777_private_endpoint_subnet.id

  private_service_connection {
    name                           = "storagePrivateEndpointConnection"
    private_connection_resource_id = azurerm_storage_account.valeriy777_storage.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "valeriy777_storage_dns" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "valeriy777_storage_dns_vnet_link" {
  name                  = "valeriy777-storage-vnet-link"
  resource_group_name   = azurerm_resource_group.valeriy777_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.valeriy777_storage_dns.name
  virtual_network_id    = azurerm_virtual_network.valeriy777_vnet.id
}

resource "azurerm_storage_share" "valeriy777_fileshare" {
  name                 = "valeriy777-fileshare"
  storage_account_name = azurerm_storage_account.valeriy777_storage.name
  quota                = 5120
}

resource "azurerm_storage_container" "tfstate_container" {
  name                  = "terraform-valeriy777-container"
  storage_account_name  = azurerm_storage_account.valeriy777_storage.name
  container_access_type = "private"
}

resource "azurerm_private_dns_a_record" "valeriy777_sql_dns_a_record" {
  name                = azurerm_sql_server.valeriy777_sql.name
  zone_name           = azurerm_private_dns_zone.valeriy777_sql_dns.name
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  ttl                 = 60
  records             = [azurerm_private_endpoint.valeriy777_sql_private_endpoint.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_a_record" "valeriy777_storage_dns_a_record" {
  name                = azurerm_storage_account.valeriy777_storage.name
  zone_name           = azurerm_private_dns_zone.valeriy777_storage_dns.name
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  ttl                 = 60
  records             = [azurerm_private_endpoint.valeriy777_storage_private_endpoint.private_service_connection[0].private_ip_address]
}