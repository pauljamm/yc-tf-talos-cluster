locals {
  name = "talos"
}

module "network" {
  source = "github.com/terraform-yc-modules/terraform-yc-vpc"

  network_name = local.name
  create_sg    = false
  private_subnets = [
    {
      zone           = "ru-central1-a",
      v4_cidr_blocks = ["10.10.0.0/24"]
    },
    {
      zone           = "ru-central1-b",
      v4_cidr_blocks = ["10.20.0.0/24"]
    },
    {
      zone           = "ru-central1-d",
      v4_cidr_blocks = ["10.40.0.0/24"]
    },
  ]
}

data "yandex_client_config" "client" {}

resource "random_string" "random" {
  length    = 4
  lower     = true
  special   = false
  min_lower = 4
}

resource "yandex_iam_service_account" "this" {
  name = "${local.name}-${random_string.random.result}"
}

resource "yandex_resourcemanager_folder_iam_member" "this" {
  folder_id = data.yandex_client_config.client.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.this.id}"
  role      = "editor"
}

data "yandex_compute_image" "talos" {
  name      = "talos-v1-9-4-metal"
  folder_id = data.yandex_client_config.client.folder_id
}

resource "yandex_compute_instance_group" "controlplane" {
  name                = "controlplane"
  service_account_id  = yandex_iam_service_account.this.id

  instance_template {
    platform_id = "standard-v2"
    resources {
      memory = var.controlplane.memory
      cores  = var.controlplane.cores
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.talos.id
        size     = var.controlplane.disk_size
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
    }
  }

  scale_policy {
    fixed_scale {
      size = var.controlplane.count
    }
  }

  allocation_policy {
    zones = var.controlplane.zones
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 1
    max_expansion   = 0
    max_deleting    = 1
  }

  load_balancer {
    target_group_name = local.name
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.this
  ]
}

resource "yandex_lb_network_load_balancer" "this" {
  name = local.name

  listener {
    name = "api"
    port = 6443
    target_port = 6443
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.controlplane.load_balancer[0].target_group_id

    healthcheck {
      name = "api"
      tcp_options {
        port = 6443
      }
    }
  }
}

# module "kubernetes" {
#   source = "github.com/terraform-yc-modules/terraform-yc-kubernetes"
# 
#   cluster_name    = local.name
# 
#   release_channel = "RAPID"
#   cluster_version = "1.31"
#   enable_cilium_policy = true
# 
#   network_id = module.network.vpc_id
# 
#   master_locations = [
#     for s in module.network.private_subnets :
#     {
#       zone      = s.zone
#       subnet_id = s.subnet_id
#     }
#   ]
# 
#   node_groups = {
#     for s in module.network.private_subnets :
#     "${local.name}-${s.zone}" => {
#       node_cores = 2
#       node_memory = 4
#       # disk_size   = 8192
#       nat = true
#       preemptible  = true
#       # fixed_scale  = {
#       #   size       = 1
#       # }
#       auto_scale    = {
#         min         = 1
#         max         = 3
#         initial     = 1
#       }
# 
#       node_locations = [
#         {
#           zone      = s.zone
#           subnet_id = s.subnet_id
#         }
#       ]
#     }
# 
#   }
# }
