#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/../.." && pwd)
TEST_ROOT=$(mktemp -d "${REPO_ROOT}/.setup-test.XXXXXX")
COMMAND_LOG="${TEST_ROOT}/commands.log"
FAKE_BIN="${TEST_ROOT}/bin"

cleanup() {
  rm -rf "${TEST_ROOT}"
}
trap cleanup EXIT

mkdir -p "${FAKE_BIN}"
mkdir -p "${TEST_ROOT}/tmp"

cat >"${FAKE_BIN}/fake-command" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

command_name=$(basename "$0")
printf '%s %s\n' "${command_name}" "$*" >>"${SETUP_TEST_LOG}"

case "${command_name}" in
  curl)
    output_file=""
    while (($#)); do
      case "$1" in
        -o | --output)
          output_file=$2
          shift 2
          ;;
        -sSLo)
          output_file=$2
          shift 2
          ;;
        *)
          shift
          ;;
      esac
    done
    if [[ -n "${output_file}" ]]; then
      : >"${output_file}"
    fi
    ;;
  dpkg)
    printf '%s\n' "amd64"
    ;;
  jq)
    printf '%s\n' "https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip"
    ;;
  lsb_release)
    printf '%s\n' "noble"
    ;;
  packer)
    printf '%s\n' "Packer v1.16.2"
    ;;
  sudo)
    cat >/dev/null
    ;;
  terraform)
    printf '%s\n' "Terraform v1.17.2"
    ;;
  terraform-docs)
    printf '%s\n' "terraform-docs version v0.25.1"
    ;;
  wget)
    printf '%s\n' "test-key"
    ;;
esac
EOF
chmod +x "${FAKE_BIN}/fake-command"

for command_name in curl dpkg gpg jq lsb_release packer sudo tar terraform terraform-docs tee wget; do
  ln -s fake-command "${FAKE_BIN}/${command_name}"
done

export SETUP_TEST_LOG="${COMMAND_LOG}"
(
  cd "${REPO_ROOT}/scripts"
  TMPDIR="${TEST_ROOT}/tmp" PATH="${FAKE_BIN}:/usr/bin:/bin" bash ./setup.sh
)

assert_logged() {
  local expected=$1
  if ! grep -Fq -- "${expected}" "${COMMAND_LOG}"; then
    printf 'Expected installer command was not run: %s\n' "${expected}" >&2
    printf '%s\n' "Recorded commands:" >&2
    cat "${COMMAND_LOG}" >&2
    return 1
  fi
}

assert_logged "wget -O - https://apt.releases.hashicorp.com/gpg"
assert_logged "sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg"
assert_logged "sudo tee /etc/apt/sources.list.d/hashicorp.list"
assert_logged "sudo apt-get install -y packer terraform"
assert_logged "https://terraform-docs.io/dl/v0.25.1/terraform-docs-v0.25.1-Linux-amd64.tar.gz"
assert_logged "terraform init"

printf '%s\n' "setup installer test passed"
