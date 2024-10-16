resource "routeros_system_script" "scripts" {
  count = length(var.scripts)

  name   = var.scripts[count.index]
  source = file("../scripts/${var.scripts[count.index]}.rsc")
}

locals {
  scriptRun = "/system/script/run [find where name=\"run\"]" 
  scriptSecure = "/system/script/run [find where name=\"secure\"];/system/script/remove [find where name=\"run\"];/system/script/remove [find where name=\"secure\"]" 
}

resource "null_resource" "run" {
  depends_on = [ routeros_system_script.scripts ]

  provisioner "local-exec" {
    command = "sshpass -p ${var.tempPass} ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.defaultAdmin}@${var.host} \"${local.scriptRun}\""
  }
}

data "routeros_files" "certs" {
  depends_on = [ null_resource.run ]
}

# resource "local_file" "certs" {
#   depends_on = [ data.routeros_files.certs ]

#   count = length(data.routeros_files.certs.files)

#   filename = "../output/${data.routeros_files.certs.files[count.index].name}"
#   content = data.routeros_files.certs.files[count.index].contents
# }

resource "routeros_file" "pubkey" {
  depends_on = [ data.routeros_files.certs ]

  name = "mikrotik_rsa.pub"
  contents = file("~/.ssh/mikrotik_rsa.pub")
}

resource "routeros_system_script" "secure" {
  depends_on = [ routeros_file.pubkey ]

  name   = "secure"
  source = templatefile("../templates/secure.rsc.tpl", {
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

