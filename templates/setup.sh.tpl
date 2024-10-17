#!/bin/bash

echo "#################### Tor ############################"

sed -i "s/#AllowInbound 1/AllowInbound 1/" /etc/tor/torsocks.conf
sed -i "s/#AllowOutboundLocalhost 1/AllowOutboundLocalhost 1/" /etc/tor/torsocks.conf

echo "#################### Test Tor ############################"

ss -nlt

echo "Public IP:"
wget -qO - https://api.ipify.org; echo

echo "Tor IP:"
torsocks wget -qO - https://api.ipify.org; echo

echo "#################### OVPN ############################"

cd /etc/openvpn

chown root:root server-pass.txt passphrase.txt client.conf
chmod 400 server-pass.txt passphrase.txt

sed -i "s/#AUTOSTART=\"all\"/AUTOSTART=\"all\"/" /etc/default/openvpn

systemctl enable openvpn@client.service
systemctl daemon-reload
service openvpn@client start

echo "################### TEST OVPN ########################"

sleep 5
ip address

echo "#################### eJabberd ############################"

cd /opt/ejabberd/conf

echo "############### Generate eJabberd Certificates ##############"

openssl genpkey -algorithm RSA -out cakey.pem
openssl req -x509 -new -key cakey.pem -out cacert.pem -days 3650 -subj "/CN=MyCA"

openssl genpkey -algorithm RSA -out server_key.pem
openssl req -new -key server_key.pem -out server.csr -subj "/CN=xmpp-server.com"

openssl x509 -req -in server.csr -CA cacert.pem -CAkey cakey.pem -CAcreateserial -out server.pem -days 3650

cat server_key.pem server.pem > fullchain.pem

mv /tmp/conf/ejabberd.yml /opt/ejabberd/conf/ejabberd.yml

systemctl restart ejabberd

ejabberdctl register admin xmpp-server.com ${xmpp-adminpass}

echo "#################### Test eJabberd ############################"

ss -tunelp | grep 5280