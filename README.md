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

```bash
# Команды для генерации конфигурации Talos будут добавлены позже
```

#### Применение конфигурации

```bash
# Команды для применения конфигурации Talos будут добавлены позже
```

#### Получение kubeconfig

```bash
# Команды для получения kubeconfig будут добавлены позже
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
- [Документация Yandex Cloud](https://cloud.yandex.ru/docs)
- [Terraform Yandex Provider](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs)
