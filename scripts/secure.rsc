:global SSHPORT

# Done during snapshot creation
# :global ADMINUSER
# :global ADMINPASS

#Disable services 
/ip service
set telnet disabled=yes
set ftp disabled=yes
set api disabled=yes
set api-ssl disabled=yes
set winbox disabled=yes
set www disabled=yes
set www-ssl disabled=yes
set ssh port=$SSHPORT

#FIXME Enable adminuser (bug is to use it in snapshot, multiple instance with the same password)
# Done during snapshot creation
# /user
# add name=$ADMINUSER password=$ADMINPASS group=full
# remove admin

# /user/ssh-keys
# import public-key-file=ssh_key.pub user=$ADMINUSER

/tool 
mac-server set allowed-interface-list=none
mac-server mac-winbox set allowed-interface-list=none
mac-server ping set enabled=no
bandwidth-server set enabled=no 

/ip 
neighbor discovery-settings set discover-interface-list=none 
proxy set enabled=no
socks set enabled=no
upnp set enabled=no
cloud set ddns-enabled=no update-time=no
ssh set strong-crypto=yes

# /lcd set enabled=no

#FIXME
#/interface print
#/interface set x disabled=yes
