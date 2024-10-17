locals {
  scriptWait = "/system/script/run [find where name=\"wait\"]ssh ;/system/script/remove [find where name=\"wait\"]" 
}

resource "hcloud_server" "mikrotik" {
  name        = "mikrotik-xmpp"
  image       = var.snapshot_id
  datacenter  = var.location
  server_type = var.type
  
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  provisioner "local-exec" {
    command = "sshpass -p ${var.tempPass} ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.defaultAdmin}@${hcloud_server.mikrotik.ipv4_address} \"${local.scriptWait}\""
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"             # Specify the key algorithm (RSA, ECDSA, etc.)
  rsa_bits  = 2048              # Specify the key size (bits) for RSA keys
}

module "routeros" {
  depends_on = [ hcloud_server.mikrotik ]

  source = "./routeros"

  host = hcloud_server.mikrotik.ipv4_address
  public_key = tls_private_key.ssh_key.public_key_openssh

  adminPass = random_password.password.result
}

