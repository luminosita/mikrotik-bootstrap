locals {
  scriptWait = "/system/script/run [find where name=\"wait\"];/system/script/remove [find where name=\"wait\"]" 

  certs = {
    for k in module.routeros.files : k.name => k.contents
  }
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
    command = "sshpass -p ${var.tempPass} ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.defaultAdmin}@${self.ipv4_address} \"${local.scriptWait}\""
  }
}

resource "random_password" "mikrotik-password" {
  length           = 16
  special          = false
  # override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "xmpp-password" {
  length           = 16
  special          = false
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

  adminPass = random_password.mikrotik-password.result
  
  defaultAdmin = var.defaultAdmin
  tempPass = var.tempPass
}

module "cloudinit" {
  depends_on = [ module.routeros ]

  source  = "../../terraform-hetzner-cloudinit" #"luminosita/cloudinit/hetzner"
  #version = "0.0.4"

  providers = {
    hcloud = hcloud
  }

  hcloud = {
    ssh_public_key_file = "~/.ssh/id_rsa.pub"
    ssh_private_key_file = "~/.ssh/id_rsa"
  }

  os = { 
    vm_base_image               = "ubuntu-22.04"
  }

  images = { 
    "xmpp" = {
      vm_user                     = "ubuntu"
      vm_ssh_public_key_files     = [
          "~/.ssh/id_rsa.pub",
          "~/.ssh/id_rsa.proxmox.pub"
          ]
      
      vm_name                     = "xmpp-server.com"

      vm_location                 = "fsn1-dc14"
      vm_server_type              = "cx22"

      vm_cloud_init               = true

      vm_ci_write_files           = {
        enabled = true
        content = [{
          path = "/etc/openvpn/server-pass.txt"
          content = local.certs["server-pass.txt"]
        }, {
          path = "/etc/openvpn/passphrase.txt"
          content = local.certs["passphrase.txt"]
        }, {
          path = "/etc/openvpn/client.conf"
          content = templatefile("../templates/client.conf.tpl", {
            ovpn_server = hcloud_server.mikrotik.ipv4_address
            port = 1194
            ca = local.certs["cert_export_MikroTik.crt"]
            client_cert = local.certs["cert_export_chat-server@MikroTik.crt"]
            client_key = local.certs["cert_export_chat-server@MikroTik.key"]
          })
        }, {
          path = "/etc/ssh/sshd_config.d/01-harden-ssh.conf"
          content = file("../config/01-harden-ssh.conf")
        }, {
          path = "/tmp/conf/ejabberd.yml"
          content = file("../config/ejabberd.yml")
        }, {
          path = "/tmp/scripts/setup.sh"
          content = templatefile("../templates/setup.sh.tpl", {
            xmpp-adminpass = random_password.xmpp-password.result
          })
          permissions = "0700"
        }] 
      }

      vm_ci_run_cmds    = {
        enabled = true
        content = [
          "hostnamectl set-hostname xmpp-server.com",
          "hostnamectl set-hostname xmpp-server.com --static",
          "curl -o /etc/apt/sources.list.d/ejabberd.list https://repo.process-one.net/ejabberd.list",
          "curl -o /etc/apt/trusted.gpg.d/ejabberd.gpg https://repo.process-one.net/ejabberd.gpg",
          "apt-get update",
          "apt-get install -y openvpn tor ejabberd",
          "/tmp/scripts/setup.sh > /var/log/setup-output.log",
        ]
      }
    }
  }
}

