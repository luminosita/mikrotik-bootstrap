# Setup Mikrotik CHR on Hetzner

### Create Mikrotik CHR VM

```bash
SNAPSHOT_ID=<mikrotik_final_image_id>
```

```bash
$ hcloud server create --image "$SNAPSHOT_ID" --location "fsn1" --type "cx22" --name "mikrotik"
```

Optionally replace mikrotik public key

```bash
$ rm ~/.ssh/mikrotik*
$ ssh-keygen -t rsa -b 2048 -f ~/.ssh/mikrotik_rsa -P ""
```

# Bootstrap Mikrotik

```bash
$ export TF_VAR_adminPass=`openssl rand -hex 16`
$ make bootstrap
```

# Test Mikrotik Connection

Login via SSH with public key

```bash
$ ssh -i ~/.ssh/mikrotik_rsa <admin_user>@<vm ip address> -p <ssh_port>
```

Copy `certs` folder to `XMPP` vm folder