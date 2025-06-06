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

# Переменные для сервисного аккаунта
variable "my-regional-account" {
  type = object({
    name                = string
    roles               = list(string)
  })
  description = "Service account params for k8s"
}

### Network

variable "subnet-zones" {
  type = list(string)
  default = [ "ru-central1-a", "ru-central1-b", "ru-central1-d" ]
}

variable "cidr" {
  type = map(list(string))
  default = {
    "cidr" = [ "10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24" ]
  }
}

# Для cloud-init.yml
variable "username" {
  description = "name of predefined user on VM"
  default     = "cloud-alex"
  type        = string
}

variable "ssh_public_key" {
  type        = string
  description = "Location of SSH public key."
  default     = "~/.ssh/id_ed25519.pub"
}

variable "packages" {
  type    = list(string)
  default = ["nano", "mc"]
  description = "Packages to install on vm creates"
}