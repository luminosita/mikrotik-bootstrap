:local SSHPORT 2222

:local ADMINUSER "${adminUser}"
:local ADMINPASS "${adminPass}"

/log info message="Creating new admin user ..."

/user
add name=$ADMINUSER password=$ADMINPASS group=full

#Keep admin for Terraform RouterOS provider
#remove admin

/log info message="Adding SSH public key for new admin user ..."

/user/ssh-keys
import public-key-file=mikrotik_rsa.pub user=$ADMINUSER

#Disable services 
/ip service
set telnet disabled=yes
set ftp disabled=yes
set api disabled=yes
set api-ssl disabled=yes
set winbox disabled=yes
set www disabled=yes
set www-ssl disabled=no
set ssh port=$SSHPORT disabled=no

/ip firewall filter
set [find where dst-port="22"] dst-port=$SSHPORT

#Cleanup
/system/script/remove [find where name="run"]


