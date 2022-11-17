/* # Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
} */



# Variables

variable "yc_token" {
  type = string
  description = "Yandex Cloud API key"
}

variable "yc_cloud_id" {
  type = string
  description = "Yandex Cloud id"
}

variable "yc_folder_id" {
  type = string
  description = "Yandex Cloud folder id"
}

# Provider

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
}

# Service accounts

resource "yandex_iam_service_account" "admin" {
  name = "admin"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = var.yc_folder_id
  role = "editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.admin.id}",
  ]
  depends_on = [
    yandex_iam_service_account.admin,
  ]
}

resource "yandex_iam_service_account_static_access_key" "static-access-key" {
  service_account_id = yandex_iam_service_account.admin.id
  depends_on = [
    yandex_iam_service_account.admin,
  ]
}
