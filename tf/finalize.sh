#!/bin/bash

RUN_SCRIPT="/system/script/run [find where name=\"run\"]"
DELETE_RUN_SCRIPT="/system/script/remove [find where name=\"run\"]"
DELETE_SETUP_SCRIPT="if ([:len [/system/script find where name=\"setup\"]] > 0) do={ /system/script/remove [find where name=\"setup\"] }"

ssh $TF_VAR_adminuser@$TF_VAR_host $RUN_SCRIPT
ssh $TF_VAR_adminuser@$TF_VAR_host -p 2222 $DELETE_RUN_SCRIPT
ssh $TF_VAR_adminuser@$TF_VAR_host -p 2222 $DELETE_SETUP_SCRIPT

mkdir ../certs

scp -P 2222 $TF_VAR_adminuser@$TF_VAR_host:/cert_export_MikroTik.crt ../certs/ca.crt
scp -P 2222 $TF_VAR_adminuser@$TF_VAR_host:/cert_export_chat-server@MikroTik.crt ../certs/client.crt
scp -P 2222 $TF_VAR_adminuser@$TF_VAR_host:/cert_export_chat-server@MikroTik.key ../certs/client.key
scp -P 2222 $TF_VAR_adminuser@$TF_VAR_host:/server-pass.txt ../certs/
scp -P 2222 $TF_VAR_adminuser@$TF_VAR_host:/passphrase.txt ../certs/

