terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.48.1"
    }
    routeros = {
      source = "terraform-routeros/routeros"
      version = "1.66.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token_secret
}

provider "routeros" {
  hosturl        = "https://${hcloud_server.mikrotik.ipv4_address}"
  username       = "admin"
  password       = "laptop01"
  insecure       = true                        
}
