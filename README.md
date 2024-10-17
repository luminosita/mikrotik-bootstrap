# Setup Mikrotik CHR on Hetzner

### Create Mikrotik CHR VM

```bash
$ export TF_VAR_tempPass=<snapshot temp password>
$ export TF_VAR_snapshot_id=<mikrotik final image id>
$ make vm

# Test Mikrotik Connection

Login via SSH with public key

```bash
$ ssh -i "output/mikrotik_rsa" admin@<vm ip address>
```

Copy `certs` folder to `XMPP` vm folder
