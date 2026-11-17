#!/usr/bin/env bash

set -euo pipefail

readonly HASHICORP_KEYRING_PATH="/usr/share/keyrings/hashicorp-archive-keyring.gpg"
readonly HASHICORP_REPOSITORY_PATH="/etc/apt/sources.list.d/hashicorp.list"
readonly TERRAFORM_DOCS_VERSION="0.24.0"
readonly TERRAFORM_MINIMUM_VERSION="1.10.0"

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
THUNDERDOME_INSTALL=$(cd -- "${SCRIPT_DIR}/.." && pwd)
export THUNDERDOME_INSTALL

install_dependencies() {
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg jq lsb-release unzip wget
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
  sudo apt-get install -y terraform
}

version_at_least() {
  local actual=$1
  local minimum=$2

  [[ "$(printf '%s\n%s\n' "${minimum}" "${actual}" | sort -V | head -n 1)" == "${minimum}" ]]
}

verify_terraform_version() {
  local actual_version

  actual_version=$(terraform version -json | jq -r '.terraform_version')
  if version_at_least "${actual_version}" "${TERRAFORM_MINIMUM_VERSION}"; then
    return 0
  fi

  printf 'Terraform %s is older than required %s; reinstalling the package.\n' \
    "${actual_version}" "${TERRAFORM_MINIMUM_VERSION}" >&2
  sudo apt-get install --reinstall -y terraform

  actual_version=$(terraform version -json | jq -r '.terraform_version')
  if ! version_at_least "${actual_version}" "${TERRAFORM_MINIMUM_VERSION}"; then
    printf 'Terraform %s is still older than required %s after reinstall.\n' \
      "${actual_version}" "${TERRAFORM_MINIMUM_VERSION}" >&2
    return 1
  fi
}

install_terraform_docs() {
  local architecture
  local archive_path
  local archive_sha256
  local platform
  local temporary_directory

  architecture=$(dpkg --print-architecture)
  case "${architecture}" in
    amd64)
      archive_sha256="9005daf969de0b50134493a2c00078b49f5f5b39d021cda7c89bf4d4f3d776d3"
      ;;
    arm64)
      archive_sha256="d12bd7b73c1fc9c64efc79f8157dd713dabd559f1ecf3cfc0f42e32279a155fd"
      ;;
    *)
      printf 'terraform-docs does not have a configured download for architecture: %s\n' \
        "${architecture}" >&2
      return 1
      ;;
  esac

  platform=linux
  temporary_directory=$(mktemp -d)
  archive_path="${temporary_directory}/terraform-docs.tar.gz"

  (
    trap 'rm -rf "${temporary_directory}"' EXIT

    curl -sSLo "${archive_path}" \
      "https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-${platform}-${architecture}.tar.gz"
    printf '%s  %s\n' "${archive_sha256}" "${archive_path}" | sha256sum --check --status
    tar -xzf "${archive_path}" -C "${temporary_directory}"
    sudo install -m 0755 "${temporary_directory}/terraform-docs" /usr/local/bin/terraform-docs
  )
}

print_versions() {
  terraform version
  terraform-docs --version
}

main() {
  install_dependencies
  install_hashicorp_repository
  install_hashicorp_tools
  verify_terraform_version
  install_terraform_docs
  print_versions

  (
    cd "${THUNDERDOME_INSTALL}/infra"
    terraform init
  )
}

main "$@"
