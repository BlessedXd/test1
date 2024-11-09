variable "location" {
  type    = string
  default = "Canada Central"
}

variable "resource_group_name" {
  type    = string
  default = "resourcegroup777"  # Задайте тут значення за замовчуванням
}

variable "app_service_name" {
  type    = string
  default = "my-app-service"  # Назва вашого App Service за замовчуванням
}

variable "admin_username" {
  type    = string
  default = "valeriy7777777"  # Ім'я користувача за замовчуванням
}

variable "admin_password" {
  type      = string
  sensitive = true
  default   = "AnastasiaOkayBro_7777"  # Пароль за замовчуванням
}

variable "storage_account_name" {
  type    = string
  default = "backendaccountvaleriy777"  # Назва облікового запису за замовчуванням
}

variable "tenant_id" {
  type    = string
   # Ваш Azure Tenant ID за замовчуванням
}

variable "tfstate_container_name" {
  type    = string
  default = "terraform-bestrong-container"  # Контейнер для Terraform State за замовчуванням
}
