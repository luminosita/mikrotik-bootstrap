locals {
  scriptSecure = "/system/script/run [find where name=\"final\"];/system/script/remove [find where name=\"final\"]" 

  fileCount = length(data.routeros_files.certs.files)
}

data "routeros_files" "certs" {
}

resource "local_file" "certs" {
  depends_on = [ data.routeros_files.certs ]

  count = 10

  filename = count.index < local.fileCount ? "../output/${data.routeros_files.certs.files[count.index].name}" : "../output/.${count.index}"
  content = count.index < local.fileCount ? data.routeros_files.certs.files[count.index].contents : ""
}

resource "routeros_file" "pubkey" {
  depends_on = [ data.routeros_files.certs ]

  name = "mikrotik_rsa.pub"
  contents = var.public_key
}

resource "routeros_system_script" "secure" {
  depends_on = [ routeros_file.pubkey ]

  name   = "final"
  source = templatefile("../templates/final.rsc.tpl", {
    adminUser = var.adminUser
    adminPass = var.adminPass
  })
}

resource "null_resource" "secure" {
  depends_on = [ routeros_system_script.secure ]

  provisioner "local-exec" {
    command = "sshpass -p ${var.tempPass} ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.defaultAdmin}@${var.host} \"${local.scriptSecure}\""
  }
}

