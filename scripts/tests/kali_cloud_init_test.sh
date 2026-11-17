#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/../.." && pwd)
source "${SCRIPT_DIR}/testlib.sh"

TEMPLATE="${REPO_ROOT}/infra/modules/kali/cloud-init.sh.tftpl"
ROOT_MODULE="${REPO_ROOT}/infra/main.tf"
TEST_ROOT=$(mktemp -d "${REPO_ROOT}/.kali-cloud-init-test.XXXXXX")
RENDERED="${TEST_ROOT}/cloud-init.sh"
ROOT_MODULE_BLOCK="${TEST_ROOT}/root-kali-module.tf"

cleanup() {
  rm -rf "${TEST_ROOT}"
}
trap cleanup EXIT

sed 's/${kali_metapackage}/kali-linux-default/g' "${TEMPLATE}" >"${RENDERED}"
sed -n '/^module "kali" {$/,/^}$/p' "${ROOT_MODULE}" >"${ROOT_MODULE_BLOCK}"
bash -n "${RENDERED}"

assert_file_contains '#!/usr/bin/env bash' "${RENDERED}"
assert_file_contains 'amazon-ssm-agent.deb' "${RENDERED}"
assert_file_contains 'systemctl enable --now amazon-ssm-agent' "${RENDERED}"
assert_file_contains 'apt-get install -y kali-linux-default' "${RENDERED}"
assert_file_contains 'SSM_MARKER=' "${RENDERED}"
assert_file_contains 'TOOLS_MARKER=' "${RENDERED}"
assert_file_contains 'if [[ -f "$SSM_MARKER" ]]' "${RENDERED}"
assert_file_contains 'if [[ -f "$TOOLS_MARKER" ]]' "${RENDERED}"

ssm_line=$(grep -n 'install_ssm_agent$' "${RENDERED}" | tail -n 1 | cut -d: -f1)
tools_line=$(grep -n 'install_kali_tools$' "${RENDERED}" | tail -n 1 | cut -d: -f1)
if [[ -z "${ssm_line}" || -z "${tools_line}" || "${ssm_line}" -ge "${tools_line}" ]]; then
  printf '%s\n' 'SSM agent installation must run before the long Kali metapackage installation.' >&2
  exit 1
fi

assert_file_excludes 'aws_access_key' "${RENDERED}"
assert_file_excludes 'aws_secret' "${RENDERED}"
assert_file_excludes 'session_token' "${RENDERED}"
assert_file_excludes 'authorized_keys' "${RENDERED}"
assert_file_excludes 'PasswordAuthentication yes' "${RENDERED}"
assert_file_excludes 'PermitRootLogin yes' "${RENDERED}"
assert_file_contains 'depends_on = [terraform_data.account_guard]' "${ROOT_MODULE_BLOCK}"
assert_file_excludes 'module.vpc]' "${ROOT_MODULE_BLOCK}"

printf '%s\n' "Kali cloud-init test passed"
