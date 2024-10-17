client
dev tun
proto tcp
remote ${ovpn_server} ${port} tcp
tun-mtu 1500
tls-client
nobind
user nobody
group nogroup
ping 15
ping-restart 45
ping-timer-rem
persist-tun
persist-key
mute-replay-warnings
verb 3
cipher AES-256-GCM
auth none
pull
auth-user-pass server-pass.txt
askpass passphrase.txt
connect-retry 1
reneg-sec 3600
remote-cert-tls server
socks-proxy localhost 9050
<ca>
${ca}
</ca>
<cert>
${client_cert}
</cert>
<key>
${client_key}
</key>
