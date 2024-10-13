module "bootstrap" {
  source  = "luminosita/bootstrap/mikrotik"
  version = "0.0.1"

  providers = {
    routeros = routeros
  }

  scripts = var.scripts
  ssh_public_key_file = "~/.ssh/id_rsa.pub"
}

locals {
  runScript = "/system/script/run [find where name=\"run\"]"
}

resource "null_resource" "run" {
  depends_on = [ module.bootstrap ]

  provisioner "local-exec" {
    command = "ssh admin@${var.host} \"${local.runScript}\"" 
  }

  provisioner "local-exec" {
    command = "mkdir certs"
  }
  
  provisioner "local-exec" {
    command = "scp -P 2222 kundun@${var.host}:/cert_export_MikroTik.crt certs/" 
  }

  provisioner "local-exec" {
    command = "scp -P 2222 kundun@${var.host}:/cert_export_chat-server@MikroTik.crt certs/" 
  }

  provisioner "local-exec" {
    command = "scp -P 2222 kundun@${var.host}:/cert_export_chat-server@MikroTik.key certs/" 
  }

  provisioner "local-exec" {
    command = "scp -P 2222 kundun@${var.host}:/server-pass.txt certs/" 
  }

  provisioner "local-exec" {
    command = "scp -P 2222 kundun@${var.host}:/passphrase.txt certs/" 
  }
}
