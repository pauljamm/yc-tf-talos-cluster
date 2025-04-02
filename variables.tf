variable "create_jump_host" {
  description = "Создавать ли jump-хост"
  type        = bool
  default     = true
}

variable "worker_count" {
  description = "Количество worker-нод"
  type        = number
  default     = 2
}

variable "worker_cores" {
  description = "Количество vCPU для worker-нод"
  type        = number
  default     = 4
}

variable "worker_memory" {
  description = "Объем памяти для worker-нод (в ГБ)"
  type        = number
  default     = 8
}

variable "worker_disk_size" {
  description = "Размер диска для worker-нод (в ГБ)"
  type        = number
  default     = 100
}
