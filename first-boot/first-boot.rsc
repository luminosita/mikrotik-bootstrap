delay 5

/log info message="Running first-boot script ..."

/interface/ethernet
:if ([:len [find]] = 0) do={
      /log error message="No ethernet interface registered."
} else={
      /log info message="Setting ethernet interface name ..."
      set 0 name=ether1      
}

/ip/dhcp-client/
:if ([:len [find]] > 0) do={
      /log info message="Removing dhcp-client ..."

      /ip/dhcp-client/remove 0
}

/log info message="Adding dhcp-client for ether1 interface ..."

/ip/dhcp-client/add interface=ether1 use-peer-dns=yes add-default-route=yes

/log info message="Removing scripts ..."

/system/scheduler
remove 0

/system/script
remove [find name="first-boot"]
remove [find name="setup"]
