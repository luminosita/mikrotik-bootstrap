resource "routeros_system_script" "scripts" {
  count = length(var.scripts)

  name   = var.scripts[count.index]
  source = file("../scripts/${var.scripts[count.index]}.rsc")
}

resource "null_resource" "run" {
  depends_on = [ routeros_system_script.scripts ]

  provisioner "local-exec" {
    command = "source ./finalize.sh"
  }
}
