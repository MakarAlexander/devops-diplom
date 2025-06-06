#!/bin/bash
set -ex  # Включает трассировку и прерывание при ошибках

# Создание бакета и сервисного аккаунта
cd bucket/ || exit 1
terraform init && \
terraform apply --auto-approve || exit 1

# Создание инфраструктуры для k8s
cd ../terraform/ || exit 1
terraform init && \
terraform apply --auto-approve || exit 1

# Получение id кластера k8s
CLUSTER_ID=$(terraform output -raw cluster_id) || exit 1

# Подключение к кластеру k8s
yc managed-kubernetes cluster get-credentials --id "$CLUSTER_ID" --external --force || exit 1

# Создание namespace для проекта
kubectl create namespace project || exit 1

# Установка мониторинга через helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && \
helm repo update && \
helm install prometheus prometheus-community/kube-prometheus-stack --namespace=project || exit 1

# Установка ingress через helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && \
helm repo update && \
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace=project || exit 1

# Применение манифестов
cd ../deploy/ || exit 1
kubectl apply -f deployment.yml || exit 1
kubectl apply -f ingress.yml || exit 1
kubectl apply -f sa_for_github.yml || exit 1

# Получение ip балансировщика
IP=$(yc load-balancer network-load-balancer list --format json | jq -r '.[0].listeners[0].address') || exit 1

# Создание DNS зоны
yc dns zone create --name amakartsev \
  --zone "amakartsev.ru." \
  --public-visibility \
  --description "Публичная зона для домена amakartsev.ru" || exit 1
# Создание А записей
for record in "@" app grafana; do
  yc dns zone add-records --name amakartsev \
    --record "$record 300 A $IP"
done

# Создание статического файла ./kube/config

CLUSTER_ID=$(yc managed-kubernetes cluster list --format json | jq -r '.[].id') || exit 1
# Запись сертификата
yc managed-kubernetes cluster get --id $CLUSTER_ID --format json | \
  jq -r .master.master_auth.cluster_ca_certificate | \
  awk '{gsub(/\\n/,"\n")}1' > ca.pem || exit 1
# Получение токена сервисного аккаунта
SA_TOKEN=$(kubectl -n kube-system get secret $(kubectl -n kube-system get secret | grep admin-user-token | awk '{print $1}') -o json | jq -r .data.token | base64 -d) || exit 1
# Получение эндпоинта для подключения
MASTER_ENDPOINT=$(yc managed-kubernetes cluster get --id $CLUSTER_ID \
  --format json | \
  jq -r .master.endpoints.external_v4_endpoint) || exit 1
# Дополняем файл конфигурации
kubectl config set-cluster sa \
  --certificate-authority=ca.pem \
  --embed-certs \
  --server=$MASTER_ENDPOINT \
  --kubeconfig=test.kubeconfig || exit 1
# Добавление токена
kubectl config set-credentials admin-user \
  --token=$SA_TOKEN \
  --kubeconfig=test.kubeconfig || exit 1
# Дополнение информации о контексте 
kubectl config set-context default \
  --cluster=sa\
  --user=admin-user \
  --kubeconfig=test.kubeconfig || exit 1
# Переключение на наш конфиг
kubectl config use-context default \
  --kubeconfig=test.kubeconfig || exit 1
