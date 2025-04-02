resource "yandex_compute_instance_group" "workers" {
  for_each = var.worker_groups

  name               = "workers-${each.key}"
  service_account_id = yandex_iam_service_account.this.id

  instance_template {
    platform_id = "standard-v2"
    resources {
      memory = each.value.memory
      cores  = each.value.cores
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.talos.id
        size     = each.value.disk_size
      }
    }
    network_interface {
      network_id = module.network.vpc_id
      subnet_ids = [
        for s in module.network.private_subnets:
          s.subnet_id
      ]
      security_group_ids = [yandex_vpc_security_group.k8s_security_group.id]
    }
    metadata = {
      # Здесь будет конфигурация worker-нод
    }
  }

  scale_policy {
    fixed_scale {
      size = each.value.count
    }
  }

  allocation_policy {
    zones = each.value.zones
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
