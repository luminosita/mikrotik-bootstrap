output "ip" {
    value = hcloud_server.mikrotik.ipv4_address
}

output "adminPass" {
    sensitive = true
    value = random_password.password.result
}

resource "local_file" "private_key" {
    filename = "../output/mikrotik_rsa"
    content = tls_private_key.ssh_key.private_key_openssh
    file_permission = "0600"
}

resource "local_file" "public_key" {
    filename = "../output/mikrotik_rsa.pub"
    content = tls_private_key.ssh_key.public_key_openssh
}
