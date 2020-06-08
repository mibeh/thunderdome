#!/bin/bash

function terraform-install() {
 
  LATEST_URL=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | grep -E -v 'rc|beta|alpha|oci' | sort -t. -k 1.2,1n -k 2,2n -k 3,3n -k 4,4n | grep .12.26 | grep -E 'linux.*amd64' | tail -1)
  curl "${LATEST_URL}" > /tmp/terraform.zip
  (cd /usr/bin && sudo unzip /tmp/terraform.zip && rm -f /tmp/terraform.zip)
  
  echo "Installed: $(/usr/bin/terraform version)"

}

function packer-install() {
  
 
  LATEST_URL=$(curl -sL https://releases.hashicorp.com/packer/index.json | jq -r '.versions[].builds[].url' | grep 'linux.*amd64' |tail -1)
  curl "${LATEST_URL}" > /tmp/packer.zip
  (cd /usr/bin && sudo unzip /tmp/packer.zip && rm -f /tmp/packer.zip)
  
  echo "Installed: $(/usr/bin/packer version)"
  
}

function terraform-docs-install() {

	curl -s https://api.github.com/repos/segmentio/terraform-docs/releases/latest \
	| grep 'browser_download_url.*linux-amd64' \
	| cut -d : -f 2,3 \
	| tr -d \" \
	| wget -qi - 
	sudo chmod +x terraform-docs-v*
	sudo cp terraform-docs-v* /usr/bin/terraform-docs
	rm -f terraform-docs-v*

	echo "Installed: $(sudo /usr/bin/terraform-docs --version)"
}

# Install dependencies
sudo apt-get install curl jq -y

terraform-install
terraform-docs-install
packer-install

# Set env var for Thunderdome install dir
export THUNDERDOME_INSTALL=$(dirname `pwd`)

# Initialize Terraform & download providers
cd ../infra && sudo -u "${USER}" terraform init
