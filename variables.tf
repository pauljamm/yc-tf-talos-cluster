variable "create_jump_host" {
  description = "Создавать ли jump-хост"
  type        = bool
  default     = true
}

variable "worker_groups" {
  description = "Конфигурация групп worker-нод"
  type = map(object({
    count     = number
    cores     = number
    memory    = number
    disk_size = number
    zones     = list(string)
  }))
  default = {
    "default" = {
      count     = 2
      cores     = 4
      memory    = 8
      disk_size = 100
      zones     = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
    }
  }
}
