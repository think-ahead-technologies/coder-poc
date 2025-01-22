
variable "zone" {
  type    = string
  default = "nbg1"
}

variable "datacenter" {
  type    = string
  default = "fsn1-dc14"
}

variable "control_plane_type" {
  type    = string
  default = "cax11"
}

variable "control_plane_count" {
  type    = number
  default = 1
}

variable "worker_type" {
  type    = string
  default = "cax31"
}

variable "worker_count" {
  type    = number
  default = 1
}
