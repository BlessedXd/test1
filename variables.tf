variable "location" {
  type    = string
  default = "Canada Central"
}

variable "resource_group_name" {
  type = string
}

variable "app_service_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "storage_account_name" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "tfstate_container_name" {
  type    = string
  default = "terraform-bestrong-container"
}

