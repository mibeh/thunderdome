#! /bin/bash

# Copy the client certificate into the downloaded config
echo "" >> ../.vpn-info/config.ovpn
echo "<cert>" >> ../.vpn-info/config.ovpn
cat ../.vpn-info/client.thunderdome.lab.crt >> ../.vpn-info/config.ovpn
echo "</cert>" >> ../.vpn-info/config.ovpn

# Copy the client key into the downloaded config
echo "<key>" >> ../.vpn-info/config.ovpn
cat ../.vpn-info/client.thunderdome.lab.key >> ../.vpn-info/config.ovpn
echo "</key>" >> ../.vpn-info/config.ovpn
