#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/../.." && pwd)
source "${SCRIPT_DIR}/testlib.sh"

TEST_ROOT=$(mktemp -d "${REPO_ROOT}/.export-vpn-test.XXXXXX")
TEST_REPO="${TEST_ROOT}/repo"
FAKE_BIN="${TEST_ROOT}/bin"
COMMAND_LOG="${TEST_ROOT}/commands.log"
OUTPUT_LOG="${TEST_ROOT}/output.log"
VPN_DIR="${TEST_REPO}/.vpn-info"
CONFIG_FILE="${VPN_DIR}/config.ovpn"

cleanup() {
  rm -rf "${TEST_ROOT}"
}
trap cleanup EXIT

mkdir -p "${FAKE_BIN}" "${VPN_DIR}" "${TEST_REPO}/scripts/lib" "${TEST_REPO}/infra"
cp "${REPO_ROOT}/scripts/export_vpn_config.sh" "${TEST_REPO}/scripts/export_vpn_config.sh"
cp "${REPO_ROOT}/scripts/lib/aws_session.sh" "${TEST_REPO}/scripts/lib/aws_session.sh"
chmod 700 "${VPN_DIR}"
printf '%s\n' 'synthetic-client-cert' >"${VPN_DIR}/client.crt"
printf '%s\n' 'synthetic-client-key' >"${VPN_DIR}/client-key"
chmod 600 "${VPN_DIR}/client-key"

cat >"${FAKE_BIN}/terraform" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'terraform %s\n' "$*" >>"${VPN_EXPORT_TEST_COMMAND_LOG}"
if [[ "${VPN_EXPORT_TEST_ENDPOINT:-present}" == "missing" ]]; then
  exit 1
fi
printf '%s\n' cvpn-endpoint-123
EOF

cat >"${FAKE_BIN}/aws" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'aws %s\n' "$*" >>"${VPN_EXPORT_TEST_COMMAND_LOG}"
if [[ "$*" == *"configure export-credentials --format process"* ]]; then
  printf '%s\n' '{"Version":1,"AccessKeyId":"ASIATEST","SecretAccessKey":"synthetic-secret","SessionToken":"synthetic-token"}'
elif [[ "$*" == *"sts get-caller-identity"* ]]; then
  printf '%s\n' "${VPN_EXPORT_TEST_ACCOUNT:-111122223333}"
elif [[ "$*" == *"ec2 export-client-vpn-client-configuration"* ]]; then
  [[ "${VPN_EXPORT_TEST_AWS_EXPORT:-success}" == "failure" ]] && exit 41
  if [[ "${VPN_EXPORT_TEST_AWS_EXPORT:-success}" == "duplicate" ]]; then
    printf '%s\n' 'client' '<cert>' 'already-embedded' '</cert>'
  else
    printf '%s\n' 'client' 'dev tun' 'remote cvpn-endpoint-123.example.invalid 443'
  fi
else
  printf 'unexpected aws invocation: %s\n' "$*" >&2
  exit 2
fi
EOF

chmod +x "${FAKE_BIN}"/*

run_export() {
  : >"${COMMAND_LOG}"
  : >"${OUTPUT_LOG}"
  env \
    PATH="${FAKE_BIN}:/usr/bin:/bin" \
    VPN_EXPORT_TEST_COMMAND_LOG="${COMMAND_LOG}" \
    VPN_EXPORT_TEST_ACCOUNT="${VPN_EXPORT_TEST_ACCOUNT:-111122223333}" \
    VPN_EXPORT_TEST_ENDPOINT="${VPN_EXPORT_TEST_ENDPOINT:-present}" \
    VPN_EXPORT_TEST_AWS_EXPORT="${VPN_EXPORT_TEST_AWS_EXPORT:-success}" \
    "${TEST_REPO}/scripts/export_vpn_config.sh" "$@" >"${OUTPUT_LOG}" 2>&1
}

expect_failure() {
  local expected=$1
  shift
  if run_export "$@"; then
    printf 'Expected export_vpn_config.sh to fail: %s\n' "${expected}" >&2
    return 1
  fi
  assert_file_contains "${expected}" "${OUTPUT_LOG}"
}

VPN_EXPORT_TEST_ENDPOINT=missing \
  expect_failure "client_vpn_endpoint_id is unavailable" \
  --account-id 111122223333 --region us-west-2
unset VPN_EXPORT_TEST_ENDPOINT
assert_file_excludes "export-client-vpn-client-configuration" "${COMMAND_LOG}"

printf '%s\n' 'known-good-profile' >"${CONFIG_FILE}"
chmod 600 "${CONFIG_FILE}"
VPN_EXPORT_TEST_AWS_EXPORT=failure \
  expect_failure "Unable to export the AWS Client VPN configuration" \
  --account-id 111122223333 --region us-west-2
unset VPN_EXPORT_TEST_AWS_EXPORT
assert_file_contains "known-good-profile" "${CONFIG_FILE}"

VPN_EXPORT_TEST_AWS_EXPORT=duplicate \
  expect_failure "already contains an embedded certificate or key" \
  --account-id 111122223333 --region us-west-2
unset VPN_EXPORT_TEST_AWS_EXPORT
assert_file_contains "known-good-profile" "${CONFIG_FILE}"

run_export --account-id 111122223333 --region us-west-2 --profile training
assert_file_contains "Client VPN profile is ready" "${OUTPUT_LOG}"
assert_file_contains "terraform -chdir=${TEST_REPO}/infra output -raw client_vpn_endpoint_id" "${COMMAND_LOG}"
assert_file_contains "aws ec2 export-client-vpn-client-configuration" "${COMMAND_LOG}"
assert_file_excludes "aws --profile training ec2 export-client-vpn-client-configuration" "${COMMAND_LOG}"
assert_file_contains "--client-vpn-endpoint-id cvpn-endpoint-123" "${COMMAND_LOG}"
assert_file_contains "--region us-west-2" "${COMMAND_LOG}"
[[ "$(stat -c '%a' "${CONFIG_FILE}")" == "600" ]]
[[ "$(grep -c '^<cert>$' "${CONFIG_FILE}")" == "1" ]]
[[ "$(grep -c '^</cert>$' "${CONFIG_FILE}")" == "1" ]]
[[ "$(grep -c '^<key>$' "${CONFIG_FILE}")" == "1" ]]
[[ "$(grep -c '^</key>$' "${CONFIG_FILE}")" == "1" ]]
assert_file_contains "synthetic-client-cert" "${CONFIG_FILE}"
assert_file_contains "synthetic-client-key" "${CONFIG_FILE}"
if find "${VPN_DIR}" -maxdepth 1 -name '.config.ovpn.*' -print -quit | grep -q .; then
  printf '%s\n' 'Temporary VPN profile was not cleaned.' >&2
  exit 1
fi

printf '%s\n' "VPN profile export test passed"
