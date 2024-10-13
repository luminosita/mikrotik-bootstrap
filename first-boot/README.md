# Deploy Mikrotik CHR 
### Step 1 - Boot into Rescue
If you have not already done so, create a server of your choice. Then boot it into the rescue system. The login credentials are shown while requesting it. To install CHR we download the Raw disk image from the [MikroTik website](https://mikrotik.com/download#chr) and extract it directly onto the virtual disk via DD.

These commands do all the necessary steps:

```bash
# curl -L https://download.mikrotik.com/routeros/7.16.1/chr-7.16.1.img.zip > mikrotik-chr.zip
# funzip mikrotik-chr.zip > mikrotik-chr.img
# dd if=mikrotik-chr.img of=/dev/sda bs=1M
```

Make a snapshot and copy snapshot ID

Delete server instance

### Step 2 - VM deployment 

```bash
$ SNAPSHOT_ID=<snapshot_id>
$ cat tf/mikrotik-vanilla-vars.tpl | sed -e "s/chr_vanilla_snapshot_id = <snapshot_id>/chr_vanilla_snapshot_id = $SNAPSHOT_ID/" > tf/mikrotik-vanilla.auto.tfvars
$ make vm
...
ip_addresses = {
  "vm_ips" = {
    "mikrotik-chr" = "49.13.70.67"
  }
}
```

### Step 3 - Approve license and change password to a temporary one

Option 1:

```bash
$ CHR_IP=<mikrotik chr ip>
$ ssh admin@$CHP_IP
```

Option 2:

Use `Hetzer Cloud Console` for the new server instance. Open terminal (`>_`, right top corner)

Login with admin and empty password (default Mikrotik CHR credentials)

### Step 4 - Deploy Setup Script

```bash
$ CHR_IP=<mikrotik chr ip>
$ ADMINUSER=<admin user name>
$ ADMINPASS=`openssl rand -hex 16`
$ echo "Random admin password: $ADMINPASS"
```

Create `scripts/setup.rsc` script

```bash
$ cat scripts/setup.tpl | sed -e "s/ADMINPASS <admin-pass>/ADMINPASS $ADMINPASS/" | sed -e "s/ADMINUSER <admin-user>/ADMINUSER $ADMINUSER/" > scripts/setup.rsc
```

Copy files to Mikrotik

```bash
$ ssh-keygen -t rsa -b 2048 -f ~/.ssh/mikrotik_rsa -P ""
$ scp ~/.ssh/mikrotik_rsa.pub scripts/first-boot.rsc scripts/setup.rsc admin@$CHR_IP:/
admin@49.13.70.67's password: <temporary password>
$ rm scripts/setup.rsc
```

Install `Setup` script

```bash
$ ssh admin@$CHR_IP "/system/script/add name=\"setup\" source=[/file get [/file find where name=\"setup.rsc\"] contents]"
admin@49.13.70.67's password: <temporary password>
$ ssh admin@$CHR_IP "/system/script/run [find name=\"setup\"]"
admin@49.13.70.67's password: <temporary password>
```

Make a snapshot and and use new snapshot ID for future Mikrotik CHR instances

Delete server instance

```bash
$ make destroy
```

### Step 5 - Deploy Final Mikrotik CHR Instance

Create new server instance with new snapshot ID

```bash
$ SNAPSHOT_ID=<new_snapshot_id>
$ cat tf/mikrotik-vanilla-vars.tpl | sed -e "s/chr_vanilla_snapshot_id = <snapshot_id>/chr_vanilla_snapshot_id = $SNAPSHOT_ID/" > tf/mikrotik-vanilla.auto.tfvars
$ make vm
...
ip_addresses = {
  "vm_ips" = {
    "mikrotik-chr" = "49.13.70.67"
  }
}
```

Add `SSH` config into `~/.ssh/config`

```bash
$ CHR_IP=<new mikrotik chr ip>
$ cat <<EOF >> ~/.ssh/config
Host $CHR_IP
    User kundun
    IdentityFile ~/.ssh/mikrotik_rsa
    IdentitiesOnly yes
EOF
```

### Step 6 - Test

Login without password prompt

```bash
$ ssh $ADMINUSER@$CHR_IP
```