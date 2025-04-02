# Talos Kubernetes Cluster в Yandex Cloud

Этот проект содержит Terraform-конфигурацию для развертывания кластера Kubernetes на базе [Talos Linux](https://www.talos.dev/) в Yandex Cloud.

## Особенности

- Автоматическое создание VPC и подсетей в трех зонах доступности
- Настройка группы безопасности с необходимыми правилами
- Развертывание control plane с балансировщиком нагрузки
- Настраиваемые группы worker-нод
- Опциональный jump-хост для управления кластером

## Требования

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [Yandex Cloud CLI](https://cloud.yandex.ru/docs/cli/quickstart)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [talosctl](https://www.talos.dev/v1.9/introduction/getting-started/#talosctl)

## Начало работы

### 1. Настройка аутентификации Yandex Cloud

```bash
yc init
```

### 2. Инициализация Terraform

```bash
terraform init
```

### 3. Настройка параметров (опционально)

Создайте файл `terraform.tfvars` для настройки параметров:

```hcl
controlplane = {
  count     = 3
  cores     = 2
  memory    = 4
  disk_size = 20
  zones     = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}

worker_groups = {
  "default" = {
    count     = 2
    cores     = 4
    memory    = 8
    disk_size = 100
    zones     = ["ru-central1-a", "ru-central1-b"]
  },
  "high-memory" = {
    count     = 1
    cores     = 4
    memory    = 16
    disk_size = 100
    zones     = ["ru-central1-d"]
  }
}

create_jump_host = true
```

### 4. Применение конфигурации

```bash
terraform apply
```

## Настройка Talos Linux

После успешного применения Terraform-конфигурации, необходимо настроить Talos Linux на созданных узлах.

### Команды talosctl для запуска кластера

#### Подготовка конфигурации

После применения Terraform вы получите IP-адреса узлов control plane и worker-нод, а также IP-адрес балансировщика нагрузки. Используйте эти адреса в следующих командах.

```bash
# Генерация конфигурации Talos
# Замените <NLB IP> на IP-адрес балансировщика нагрузки
talosctl gen config talos-yc https://<NLB IP>:6443

# Настройка переменной окружения для talosconfig
export TALOSCONFIG=$(pwd)/talosconfig
```

#### Применение конфигурации

```bash
# Настройка endpoint для talosctl
# Замените <CP1 IP> на IP-адрес первого узла control plane
talosctl config endpoint <CP1 IP>
talosctl config node <CP1 IP>

# Применение конфигурации для первого узла control plane
talosctl apply-config --insecure --nodes <CP1 IP> --file controlplane.yaml

# Инициализация кластера (только для первого узла control plane)
talosctl bootstrap

# Применение конфигурации для остальных узлов control plane
talosctl apply-config --insecure --nodes <CP2 IP> --file controlplane.yaml
talosctl apply-config --insecure --nodes <CP3 IP> --file controlplane.yaml

# Применение конфигурации для worker-нод
# Повторите для каждой worker-ноды
talosctl apply-config --insecure --nodes <WORKER1 IP> --file worker.yaml
talosctl apply-config --insecure --nodes <WORKER2 IP> --file worker.yaml
# ... и так далее для всех worker-нод
```

#### Получение kubeconfig

После успешного запуска кластера, получите kubeconfig для доступа к Kubernetes:

```bash
# Получение kubeconfig
talosctl kubeconfig --nodes <CP1 IP> -f

# Проверка доступа к кластеру
kubectl --kubeconfig=kubeconfig get nodes
```

## Доступ к кластеру

После настройки Talos и получения kubeconfig, вы можете подключиться к кластеру:

```bash
kubectl --kubeconfig=kubeconfig get nodes
```

## Удаление ресурсов

Для удаления всех созданных ресурсов:

```bash
terraform destroy
```

## Дополнительная информация

- [Документация Talos Linux](https://www.talos.dev/v1.9/introduction/what-is-talos/)
- [Документация Yandex Cloud](https://yandex.cloud/docs)
- [Terraform Yandex Provider](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs)
