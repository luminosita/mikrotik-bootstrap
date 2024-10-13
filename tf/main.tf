resource "routeros_system_script" "scripts" {
  count = length(var.scripts)

  name   = var.scripts[count.index]
  source = file("../scripts/${var.scripts[count.index]}.rsc")
}

locals {
  runScript = "/system/script/run [find where name=\"run\"]"
}

resource "null_resource" "run" {
  depends_on = [ routeros_system_script.scripts ]

  provisioner "local-exec" {
    command = "ssh ${var.adminuser}@${var.host} \"${local.runScript}\"" 
  }

  provisioner "local-exec" {
    command = "mkdir ../certs"
  }
  
  provisioner "local-exec" {
    command = "scp -P 2222 kundun@${var.host}:/cert_export_MikroTik.crt ../certs/ca.crt" 
  }

  provisioner "local-exec" {
    command = "scp -P 2222 kundun@${var.host}:/cert_export_chat-server@MikroTik.crt ../certs/server.crt" 
  }

  provisioner "local-exec" {
    command = "scp -P 2222 kundun@${var.host}:/cert_export_chat-server@MikroTik.key ../certs/server.key" 
  }

  provisioner "local-exec" {
    command = "scp -P 2222 kundun@${var.host}:/server-pass.txt ../certs/" 
  }

  provisioner "local-exec" {
    command = "scp -P 2222 kundun@${var.host}:/passphrase.txt ../certs/" 
  }
}
