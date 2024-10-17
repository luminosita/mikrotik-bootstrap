output "mikrotik" {
    sensitive = true 
    value = {
        ip = hcloud_server.mikrotik.ipv4_address
        adminPass = random_password.mikrotik-password.result
    }
}

output "xmpp" {
    sensitive = true
    value = {
        result = module.cloudinit.result
        adminPass = random_password.xmpp-password.result
    }
}

# resource "local_file" "cloud-init" {
#     for_each = module.cloudinit.result 
#     filename = "../output/cloud-init-${each.key}.conf"
#     content = each.value.cloud-init
# }

resource "local_file" "private_key" {
    filename = "../output/mikrotik_rsa"
    content = tls_private_key.ssh_key.private_key_openssh
    file_permission = "0600"
}

resource "local_file" "public_key" {
    filename = "../output/mikrotik_rsa.pub"
    content = tls_private_key.ssh_key.public_key_openssh
}
