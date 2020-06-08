#! /bin/bash

mkdir -p /tmp/vpn-setup && cd /tmp/vpn-setup
wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.7/EasyRSA-3.0.7.tgz
tar -xvf EasyRSA-3.0.7.tgz && rm EasyRSA-3.0.7.tgz && cd EasyRSA-3.0.7

# Generate the certs and keys
./easyrsa init-pki
EASYRSA_BATCH="true" EASYRSA_REQ_CN=thunderdome.lab ./easyrsa build-ca --batch  nopass
./easyrsa build-server-full server.thunderdome.lab nopass
./easyrsa build-client-full client.thunderdome.lab nopass

# Copy files to project directory
mkdir -p $THUNDERDOME_INSTALL/.vpn-info
cp pki/ca.crt $THUNDERDOME_INSTALL/.vpn-info
cp pki/issued/server.thunderdome.lab.crt $THUNDERDOME_INSTALL/.vpn-info
cp pki/issued/client.thunderdome.lab.crt $THUNDERDOME_INSTALL/.vpn-info
cp pki/private/server.thunderdome.lab.key $THUNDERDOME_INSTALL/.vpn-info
cp pki/private/client.thunderdome.lab.key $THUNDERDOME_INSTALL/.vpn-info
cd $THUNDERDOME_INSTALL/.vpn-info

echo "[*] Uploading certificate to ACM"

# Import Certificate to ACM and get certificate ARN
VPN_CERT_ARN=$(aws acm import-certificate --certificate file://server.thunderdome.lab.crt \
							--private-key file://server.thunderdome.lab.key \
							--certificate-chain file://ca.crt --region us-east-1\
							| jq '.CertificateArn' | tr -d '"')

echo "[*] Done"

# Remove unneeded files
rm -rf /tmp/vpn-setup
