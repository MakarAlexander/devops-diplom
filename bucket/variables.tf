# cloud vars
variable "token" {
 type        = string
 description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

# Переменные для сервисного аккаунта и бакета

variable "sa_name" {
  type = string
  default = "sa-diplom"
}

variable "bucket_name" {
  type = string
  default = "amakartsev-bucket"
  description = "Name of S3 bucket for backend"
}