terraform {
  required_providers {
    routeros = {
      source = "terraform-routeros/routeros"
      version = "1.66.0"
    }
  }
}

provider "routeros" {
  hosturl        = "http://${var.host}"        
  username       = var.defaultAdmin
  password       = var.tempPass
  insecure       = true                        
}

