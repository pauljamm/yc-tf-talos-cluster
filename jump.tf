data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts-oslogin"
}

resource "yandex_compute_instance" "jump" {
  name        = "${local.name}-jump"
  platform_id = "standard-v2"
  zone        = module.network.private_subnets["10.10.0.0/24"].zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size = 20
    }
  }

  network_interface {
    subnet_id = module.network.private_subnets["10.10.0.0/24"].subnet_id
    nat = "true"
  }
  metadata = {
    enable-oslogin = true
  }

  allow_stopping_for_update = "true"

}
