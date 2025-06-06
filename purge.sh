#!/bin/sh
set -ex  # Включает трассировку и прерывание при ошибках

# Удаление DNS зоны и записей
yc dns zone delete amakartsev

# Удаление инфраструктуры
cd terraform/ || exit 1
terraform destroy --auto-approve || exit 1

# Удаление бакета и сервисного аккаунта
cd ../bucket/ || exit 1
terraform destroy --auto-approve || exit 1