module "cloudinit" {
  source  = "../../terraform-hetzner-cloudinit" #"luminosita/cloudinit/hetzner"
  #version = "0.0.2"

  providers = {
    hcloud = hcloud
  }

  hcloud = {
    ssh_public_key_file = "~/.ssh/id_rsa.pub"
  }

  os = { 
    #vm_base_image = "ubuntu-22.04"
    vm_snapshot_id         = var.chr_vanilla_snapshot_id
  }

  images = { 
    "mikrotik-chr" = {
      vm_name             = "mikrotik-chr"

      vm_location         = "fsn1-dc14"
      vm_server_type      = "cx22"

      vm_cloud_init       = false
    }
  }
}
