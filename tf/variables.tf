variable "hcloud_token_secret" {
  type = string
}

variable "location" {
  type = string
  default = "fsn1-dc14"
}

variable "type" {
  type = string
  default = "cx22"
}

variable "snapshot_id" {
  type = string
}

variable "defaultAdmin" {
  type = string
  default = "admin"
}

variable "tempPass" {
  type = string
}
