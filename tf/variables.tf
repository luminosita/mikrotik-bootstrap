variable "host" {
  type = string
}

variable "defaultAdmin" {
  type = string
  default = "admin"
}

variable "tempPass" {
  type = string
}

variable "adminUser" {
  type = string
}

variable "adminPass" {
  type = string
}

variable "scripts" {
  type = list(string)
}
