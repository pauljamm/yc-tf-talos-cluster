data "yandex_compute_image" "ubuntu" {
  count  = var.create_jump_host ? 1 : 0
  family = "ubuntu-2404-lts-oslogin"
}

resource "yandex_compute_instance" "jump" {
  count       = var.create_jump_host ? 1 : 0
  name        = "${local.name}-jump"
  platform_id = "standard-v2"
  zone        = module.network.private_subnets["10.10.0.0/24"].zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu[0].id
      size     = 20
    }
  }

  network_interface {
    subnet_id = module.network.private_subnets["10.10.0.0/24"].subnet_id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.k8s_security_group.id]
  }
  
  metadata = {
    enable-oslogin = true
    user-data      = file("${path.module}/scripts/install_tools.sh")
  }

  allow_stopping_for_update = true
}
