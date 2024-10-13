# Setup Mikrotik CHR on Hetzner

### Create Mikrotik CHR VM

Clone `mikrotik-<provider>` repository

```bash
$ make vm
...
ip_addresses = {
  "vm_ips" = {
    "mikrotik-chr" = "91.107.206.126"
  }
}
```

Approve license and change password to temporary passsword

```bash
$ ssh admin@<vm ip address>
```

# Bootstrap Mikrotik

```bash
$ make bootstrap
admin@91.107.206.126's password: <temporary password>
```

# Test Mikrotik Connection

Login via SSH with public key

```bash
$ ssh <admin_user>@<vm ip address> -p <ssh_port>
```

Copy `certs` folder to `XMPP` vm folder