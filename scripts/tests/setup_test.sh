#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/../.." && pwd)
source "${SCRIPT_DIR}/testlib.sh"

TEST_ROOT=$(mktemp -d "${REPO_ROOT}/.setup-test.XXXXXX")
COMMAND_LOG="${TEST_ROOT}/commands.log"
FAKE_BIN="${TEST_ROOT}/bin"
TERRAFORM_VERSION_FILE="${TEST_ROOT}/terraform-version"

cleanup() {
  rm -rf "${TEST_ROOT}"
}
trap cleanup EXIT

mkdir -p "${FAKE_BIN}"
mkdir -p "${TEST_ROOT}/tmp"
printf '%s\n' "0.12.26" >"${TERRAFORM_VERSION_FILE}"

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
    input=$(cat)
    if [[ "$*" == "-r .terraform_version" ]]; then
      sed -n 's/.*"terraform_version":"\([^"]*\)".*/\1/p' <<<"${input}"
    fi
    ;;
  lsb_release)
    printf '%s\n' "noble"
    ;;
  sudo)
    if [[ "$*" == "apt-get install --reinstall -y terraform" ]]; then
      printf '%s\n' "1.17.2" >"${SETUP_TEST_TERRAFORM_VERSION_FILE}"
    fi
    cat >/dev/null
    ;;
  sha256sum)
    checksum_input=$(cat)
    printf 'sha256sum-input %s\n' "${checksum_input}" >>"${SETUP_TEST_LOG}"
    ;;
  terraform)
    if [[ "${1:-}" == "version" && "${2:-}" == "-json" ]]; then
      printf '{"terraform_version":"%s"}\n' "$(<"${SETUP_TEST_TERRAFORM_VERSION_FILE}")"
    else
      printf 'Terraform v%s\n' "$(<"${SETUP_TEST_TERRAFORM_VERSION_FILE}")"
    fi
    ;;
  terraform-docs)
    printf '%s\n' "terraform-docs version v0.24.0"
    ;;
  wget)
    printf '%s\n' "test-key"
    ;;
esac
EOF
chmod +x "${FAKE_BIN}/fake-command"

for command_name in curl dpkg gpg jq lsb_release sha256sum sudo tar terraform terraform-docs tee wget; do
  ln -s fake-command "${FAKE_BIN}/${command_name}"
done

export SETUP_TEST_LOG="${COMMAND_LOG}"
export SETUP_TEST_TERRAFORM_VERSION_FILE="${TERRAFORM_VERSION_FILE}"
(
  cd "${REPO_ROOT}/scripts"
  TMPDIR="${TEST_ROOT}/tmp" PATH="${FAKE_BIN}:/usr/bin:/bin" bash ./setup.sh
)

assert_file_contains "wget -O - https://apt.releases.hashicorp.com/gpg" "${COMMAND_LOG}"
assert_file_contains "sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg" "${COMMAND_LOG}"
assert_file_contains "sudo tee /etc/apt/sources.list.d/hashicorp.list" "${COMMAND_LOG}"
assert_file_contains "sudo apt-get install -y terraform" "${COMMAND_LOG}"
assert_file_contains "sudo apt-get install --reinstall -y terraform" "${COMMAND_LOG}"
assert_file_contains "sudo apt-get install -y ca-certificates curl gnupg jq lsb-release unzip wget" "${COMMAND_LOG}"
assert_file_contains "https://github.com/terraform-docs/terraform-docs/releases/download/v0.24.0/terraform-docs-v0.24.0-linux-amd64.tar.gz" "${COMMAND_LOG}"
assert_file_contains "9005daf969de0b50134493a2c00078b49f5f5b39d021cda7c89bf4d4f3d776d3" "${COMMAND_LOG}"
assert_file_contains "terraform version -json" "${COMMAND_LOG}"
assert_file_contains "terraform init" "${COMMAND_LOG}"
assert_file_excludes "packer" "${COMMAND_LOG}"

if [[ "$(<"${TERRAFORM_VERSION_FILE}")" != "1.17.2" ]]; then
  printf '%s\n' "Terraform executable was not repaired by reinstall" >&2
  exit 1
fi

printf '%s\n' "setup installer test passed"
