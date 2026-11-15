#!/usr/bin/env bash

set -euo pipefail

readonly HASHICORP_KEYRING_PATH="/usr/share/keyrings/hashicorp-archive-keyring.gpg"
readonly HASHICORP_REPOSITORY_PATH="/etc/apt/sources.list.d/hashicorp.list"
readonly TERRAFORM_DOCS_VERSION="${TERRAFORM_DOCS_VERSION:-0.25.1}"

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
THUNDERDOME_INSTALL=$(cd -- "${SCRIPT_DIR}/.." && pwd)
export THUNDERDOME_INSTALL

install_dependencies() {
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg jq lsb-release wget
}

install_hashicorp_repository() {
  local architecture
  local distribution_codename

  wget -O - https://apt.releases.hashicorp.com/gpg \
    | sudo gpg --dearmor --yes -o "${HASHICORP_KEYRING_PATH}"

  architecture=$(dpkg --print-architecture)
  distribution_codename=$(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs)
  if [[ -z "${distribution_codename}" ]]; then
    printf '%s\n' "Unable to determine the Ubuntu or Debian release codename." >&2
    return 1
  fi

  printf 'deb [arch=%s signed-by=%s] https://apt.releases.hashicorp.com %s main\n' \
    "${architecture}" "${HASHICORP_KEYRING_PATH}" "${distribution_codename}" \
    | sudo tee "${HASHICORP_REPOSITORY_PATH}" >/dev/null

  sudo apt-get update
}

install_hashicorp_tools() {
  sudo apt-get install -y packer terraform
}

install_terraform_docs() {
  local architecture
  local archive_path
  local platform
  local temporary_directory

  architecture=$(dpkg --print-architecture)
  case "${architecture}" in
    amd64 | arm64) ;;
    *)
      printf 'terraform-docs does not have a configured download for architecture: %s\n' \
        "${architecture}" >&2
      return 1
      ;;
  esac

  platform=$(uname -s)
  temporary_directory=$(mktemp -d)
  archive_path="${temporary_directory}/terraform-docs.tar.gz"

  (
    trap 'rm -rf "${temporary_directory}"' EXIT

    curl -sSLo "${archive_path}" \
      "https://terraform-docs.io/dl/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-${platform}-${architecture}.tar.gz"
    tar -xzf "${archive_path}" -C "${temporary_directory}"
    sudo install -m 0755 "${temporary_directory}/terraform-docs" /usr/local/bin/terraform-docs
  )
}

print_versions() {
  terraform version
  packer version
  terraform-docs --version
}

main() {
  install_dependencies
  install_hashicorp_repository
  install_hashicorp_tools
  install_terraform_docs
  print_versions

  (
    cd "${THUNDERDOME_INSTALL}/infra"
    terraform init
  )
}

main "$@"
