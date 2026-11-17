#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/../.." && pwd)
source "${SCRIPT_DIR}/testlib.sh"

TEST_ROOT=$(mktemp -d "${REPO_ROOT}/.prepare-vpn-test.XXXXXX")
TEST_REPO="${TEST_ROOT}/repo"
FAKE_BIN="${TEST_ROOT}/bin"
COMMAND_LOG="${TEST_ROOT}/commands.log"
OUTPUT_LOG="${TEST_ROOT}/output.log"
TEMP_ROOT="${TEST_ROOT}/tmp"
VPN_DIR="${TEST_REPO}/.vpn-info"

cleanup() {
  rm -rf "${TEST_ROOT}"
}
trap cleanup EXIT

mkdir -p "${FAKE_BIN}" "${TEMP_ROOT}" "${TEST_REPO}/scripts/lib"
cp "${REPO_ROOT}/scripts/prepare_vpn.sh" "${TEST_REPO}/scripts/prepare_vpn.sh"
cp "${REPO_ROOT}/scripts/lib/aws_session.sh" "${TEST_REPO}/scripts/lib/aws_session.sh"

cat >"${FAKE_BIN}/aws" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'aws %s\n' "$*" >>"${VPN_TEST_COMMAND_LOG}"
if [[ "$*" == *"configure export-credentials --format process"* ]]; then
  printf '%s\n' '{"Version":1,"AccessKeyId":"ASIATEST","SecretAccessKey":"synthetic-secret","SessionToken":"synthetic-token"}'
elif [[ "$*" == *"sts get-caller-identity"* ]]; then
  printf '%s\n' "${VPN_TEST_ACCOUNT:-111122223333}"
elif [[ "$*" == *"acm import-certificate"* ]]; then
  [[ "${VPN_TEST_ACM_IMPORT:-success}" == "failure" ]] && exit 41
  printf '%s\n' '{"CertificateArn":"arn:aws:acm:us-west-2:111122223333:certificate/test"}'
else
  printf 'unexpected aws invocation: %s\n' "$*" >&2
  exit 2
fi
EOF

cat >"${FAKE_BIN}/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'curl %s\n' "$*" >>"${VPN_TEST_COMMAND_LOG}"
output=
while (($# > 0)); do
  if [[ "$1" == "--output" ]]; then
    output=$2
    shift 2
  else
    shift
  fi
done
printf '%s\n' 'synthetic EasyRSA archive' >"${output}"
EOF

cat >"${FAKE_BIN}/sha256sum" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
read -r expected archive
archive=${archive#\*}
archive=${archive# }
if [[ "${VPN_TEST_CHECKSUM:-valid}" == "valid" && -f "${archive}" ]]; then
  printf '%s: OK\n' "${archive}"
  exit 0
fi
printf '%s: FAILED\n' "${archive}" >&2
exit 1
EOF

cat >"${FAKE_BIN}/tar" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'tar %s\n' "$*" >>"${VPN_TEST_COMMAND_LOG}"
destination=
while (($# > 0)); do
  if [[ "$1" == "-C" ]]; then
    destination=$2
    shift 2
  else
    shift
  fi
done
mkdir -p "${destination}/EasyRSA-3.2.7"
cat >"${destination}/EasyRSA-3.2.7/easyrsa" <<'EASYRSA'
#!/usr/bin/env bash
set -euo pipefail
printf 'easyrsa %s\n' "$*" >>"${VPN_TEST_COMMAND_LOG}"
case "${1:-}" in
  init-pki)
    mkdir -p pki/issued pki/private
    ;;
  build-ca)
    printf 'synthetic-ca-%s\n' "${VPN_TEST_GENERATION:-one}" >pki/ca.crt
    ;;
  build-server-full)
    printf 'synthetic-server-cert-%s\n' "${VPN_TEST_GENERATION:-one}" >"pki/issued/$2.crt"
    printf 'synthetic-server-key-%s\n' "${VPN_TEST_GENERATION:-one}" >"pki/private/$2.key"
    ;;
  build-client-full)
    printf 'synthetic-client-cert-%s\n' "${VPN_TEST_GENERATION:-one}" >"pki/issued/$2.crt"
    printf 'synthetic-client-key-%s\n' "${VPN_TEST_GENERATION:-one}" >"pki/private/$2.key"
    ;;
  *)
    exit 2
    ;;
esac
EASYRSA
chmod +x "${destination}/EasyRSA-3.2.7/easyrsa"
EOF

chmod +x "${FAKE_BIN}"/*

run_prepare() {
  : >"${COMMAND_LOG}"
  : >"${OUTPUT_LOG}"
  (
    cd "${TEST_ROOT}"
    env \
      PATH="${FAKE_BIN}:/usr/bin:/bin" \
      TMPDIR="${TEMP_ROOT}" \
      VPN_TEST_COMMAND_LOG="${COMMAND_LOG}" \
      VPN_TEST_ACCOUNT="${VPN_TEST_ACCOUNT:-111122223333}" \
      VPN_TEST_CHECKSUM="${VPN_TEST_CHECKSUM:-valid}" \
      VPN_TEST_ACM_IMPORT="${VPN_TEST_ACM_IMPORT:-success}" \
      VPN_TEST_GENERATION="${VPN_TEST_GENERATION:-one}" \
      "${TEST_REPO}/scripts/prepare_vpn.sh" "$@"
  ) >"${OUTPUT_LOG}" 2>&1
}

expect_failure() {
  local expected=$1
  shift
  if run_prepare "$@"; then
    printf 'Expected prepare_vpn.sh to fail: %s\n' "${expected}" >&2
    return 1
  fi
  assert_file_contains "${expected}" "${OUTPUT_LOG}"
}

VPN_TEST_ACCOUNT=111111111111 \
  expect_failure "does not match expected 111122223333" \
  --account-id 111122223333 --region us-west-2
unset VPN_TEST_ACCOUNT
assert_file_excludes "curl " "${COMMAND_LOG}"

VPN_TEST_CHECKSUM=invalid \
  expect_failure "EasyRSA archive checksum did not match" \
  --account-id 111122223333 --region us-west-2
unset VPN_TEST_CHECKSUM
assert_file_excludes "acm import-certificate" "${COMMAND_LOG}"
if find "${TEMP_ROOT}" -mindepth 1 -print -quit | grep -q .; then
  printf '%s\n' 'Disposable PKI workspace was not cleaned after checksum failure.' >&2
  exit 1
fi

run_prepare --account-id 111122223333 --region us-west-2 --profile training
assert_file_contains "VPN certificate material is ready" "${OUTPUT_LOG}"
assert_file_contains "aws acm import-certificate" "${COMMAND_LOG}"
assert_file_excludes "aws --profile training acm import-certificate" "${COMMAND_LOG}"
assert_file_contains "--region us-west-2" "${COMMAND_LOG}"
assert_file_contains "--certificate fileb://" "${COMMAND_LOG}"
assert_file_contains "/issued/server.thunderdome.lab.crt" "${COMMAND_LOG}"
assert_file_contains "--private-key fileb://" "${COMMAND_LOG}"
assert_file_contains "/private/server.thunderdome.lab.key" "${COMMAND_LOG}"
assert_file_contains "--certificate-chain fileb://" "${COMMAND_LOG}"
assert_file_contains "/pki/ca.crt" "${COMMAND_LOG}"
assert_file_excludes "client-key" "${COMMAND_LOG}"
[[ "$(stat -c '%a' "${VPN_DIR}")" == "700" ]]
[[ "$(stat -c '%a' "${VPN_DIR}/server-key")" == "600" ]]
[[ "$(stat -c '%a' "${VPN_DIR}/client-key")" == "600" ]]
[[ "$(stat -c '%a' "${VPN_DIR}/ca.crt")" == "644" ]]
[[ "$(stat -c '%a' "${VPN_DIR}/client.crt")" == "644" ]]
assert_file_contains "synthetic-client-key-one" "${VPN_DIR}/client-key"
assert_file_contains "arn:aws:acm:us-west-2:111122223333:certificate/test" "${VPN_DIR}/server-certificate-arn"
if find "${TEMP_ROOT}" -mindepth 1 -print -quit | grep -q .; then
  printf '%s\n' 'Disposable PKI workspace was not cleaned after success.' >&2
  exit 1
fi

expect_failure "already exists; use --rotate" \
  --account-id 111122223333 --region us-west-2
assert_file_contains "synthetic-client-key-one" "${VPN_DIR}/client-key"

VPN_TEST_GENERATION=two run_prepare \
  --account-id 111122223333 --region us-west-2 --rotate
assert_file_contains "synthetic-client-key-two" "${VPN_DIR}/client-key"
assert_file_excludes "synthetic-client-key-one" "${VPN_DIR}/client-key"

VPN_TEST_ACM_IMPORT=failure VPN_TEST_GENERATION=three \
  expect_failure "existing local material was preserved" \
  --account-id 111122223333 --region us-west-2 --rotate
assert_file_contains "synthetic-client-key-two" "${VPN_DIR}/client-key"
if find "${TEMP_ROOT}" -mindepth 1 -print -quit | grep -q .; then
  printf '%s\n' 'Disposable PKI workspace was not cleaned after ACM failure.' >&2
  exit 1
fi

printf '%s\n' "VPN certificate preparation test passed"
