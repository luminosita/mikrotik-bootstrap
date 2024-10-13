# Basic Mikrotik Setup

:global CN

:global GATEWAY
:global GATEWAYMASK
:global NETWORK
:global NETMASK

:global DHCPPOOL

:global SSHPORT

:local macAddress [/interface get 0 mac-address]

/log info message="Setting MAC address to bridge interface"
#define bridge MAC address

/interface bridge
:if ([:len [find]] = 0) do={
    add admin-mac=$macAddress auto-mac=no comment=defconf name=bridge
} else={
	set 0 admin-mac=$macAddress auto-mac=no comment=defconf name=bridge
}

#Define bridge for all present network interfaces
/interface bridge port
:if ([:len [find]] = 0) do={
    add bridge=bridge comment=defconf interface=ether1
}

/log info message="Setting main IP address, dhcp and vpn pools, dhcp server ..."
#Set main IP address, dhcp and vpn pools, dhcp server
/ip address
add address=$GATEWAYMASK comment=defconf interface=bridge network=$NETWORK

/ip cloud
set ddns-enabled=yes ddns-update-interval=1m update-time=yes

#:if ([:len [find]] = 0) do={
#    add address=$GATEWAYMASK comment=defconf interface=bridge network=$NETWORK
#} else={
#    set 0 address=$GATEWAYMASK comment=defconf interface=bridge network=$NETWORK
#}

/ip pool
:if ([:len [find]] = 0) do={
    add name="DHCPPOOL" ranges=$DHCPPOOL
} else={
    set [ find name="DHCPPOOL" ] ranges=$DHCPPOOL
}

/ip dhcp-server
:if ([:len [find]] = 0) do={
    add address-pool="DHCPPOOL" interface=bridge name=dhcp1
} 

/ip dhcp-server network
:if ([:len [find]] = 0) do={
    add address=$NETMASK comment=defconf dns-server=$GATEWAY gateway=$GATEWAY
} else={
    set 0 address=$NETMASK comment=defconf dns-server=$GATEWAY gateway=$GATEWAY
}

/ip dns
set allow-remote-requests=yes
/ip dns static
add address=$GATEWAY comment=defconf name=router.lan

## Set WebFig certificate for HTTPS
/ip service
set www-ssl certificate="webfig@$CN" disabled=no

/system logging
add disabled=yes topics=dns,packet