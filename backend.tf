terraform {
  backend "azurerm" {
    resource_group_name   = "backendresourcegroup777"
    storage_account_name  = "backendaccountvaleriy777"
    container_name        = "tfstate"
    key                    = "backend777.tfstate"
    access_key            = var.storage_account_access_key
  }
}
