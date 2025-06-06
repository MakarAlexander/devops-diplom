resource "yandex_kubernetes_cluster" "k8s-regional" {
  name = "k8s-regional"
  network_id = yandex_vpc_network.app-net.id
  master {
    public_ip = true
    dynamic "master_location" {
      for_each = yandex_vpc_subnet.app-subnet-zones
      content {
        subnet_id = master_location.value["id"]
        zone      = master_location.value["zone"]
      }
    }
    security_group_ids = [yandex_vpc_security_group.regional-k8s-sg.id]
  }
  service_account_id      = yandex_iam_service_account.my-regional-account.id
  node_service_account_id = yandex_iam_service_account.my-regional-account.id
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-roles
  ]
  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
}

# Создание сервисного аккаунта для k8s кластера
resource "yandex_iam_service_account" "my-regional-account" {
  name        = var.my-regional-account.name
  description = "K8S regional service account"
}

# Выдача ролей согласно списку
resource "yandex_resourcemanager_folder_iam_member" "k8s-roles" {
  depends_on = [yandex_iam_service_account.my-regional-account]
  for_each   = toset(var.my-regional-account.roles)
  folder_id  = var.folder_id
  role       = each.value
  member    = "serviceAccount:${yandex_iam_service_account.my-regional-account.id}"
}

# Ключ Yandex Key Management Service для шифрования важной информации
resource "yandex_kms_symmetric_key" "kms-key" {
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
}
