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
  username       = "admin"                     
  password       = var.temp_password           
  insecure       = true                        
}

