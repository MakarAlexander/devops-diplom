# Сервисный аккаунт для бакета
resource "yandex_iam_service_account" "sa-diplom" {
  name = var.sa_name
}

# Выдача прав "editor"
resource "yandex_resourcemanager_folder_iam_member" "diplom-editor" {
  folder_id = var.folder_id
  role = "editor"
  member = "serviceAccount:${yandex_iam_service_account.sa-diplom.id}"
  depends_on = [ yandex_iam_service_account.sa-diplom ]
}

# Создание статического ключа для бакета
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa-diplom.id
  description = "static access key"
}

# Использование ключей для бакета
resource "yandex_storage_bucket" "amakartsev-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = var.bucket_name
  acl = "private"
  force_destroy = true
  depends_on = [ yandex_resourcemanager_folder_iam_member.diplom-editor ]
}

# Создание локального файла с кредами для бакета
resource "local_file" "credfile" {
  content = <<EOT
[default]
aws_access_key_id = ${yandex_iam_service_account_static_access_key.sa-static-key.access_key}
aws_secret_access_key = ${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}
EOT
  filename = "../terraform/credfile.key"
}