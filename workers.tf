resource "yandex_compute_instance_group" "workers" {
  name                = "workers"
  service_account_id  = yandex_iam_service_account.this.id

  instance_template {
    platform_id = "standard-v2"
    resources {
      memory = var.worker_memory
      cores  = var.worker_cores
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.talos.id
        size     = var.worker_disk_size
      }
    }
    network_interface {
      network_id = module.network.vpc_id
      subnet_ids = [
        for s in module.network.private_subnets:
          s.subnet_id
      ]
    }
    metadata = {
      # Здесь будет конфигурация worker-нод
    }
  }

  scale_policy {
    fixed_scale {
      size = var.worker_count
    }
  }

  allocation_policy {
    zones = [
      "ru-central1-a",
      "ru-central1-b",
      "ru-central1-d"
    ]
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 1
    max_expansion   = 0
    max_deleting    = 1
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.this
  ]
}
