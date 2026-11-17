#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/../.." && pwd)
source "${SCRIPT_DIR}/testlib.sh"

TEST_ROOT=$(mktemp -d "${REPO_ROOT}/.terraform-wrapper-test.XXXXXX")
FAKE_BIN="${TEST_ROOT}/bin"
COMMAND_LOG="${TEST_ROOT}/commands.log"
OUTPUT_LOG="${TEST_ROOT}/output.log"

cleanup() {
  rm -rf "${TEST_ROOT}"
}
trap cleanup EXIT

mkdir -p "${FAKE_BIN}"

cat >"${FAKE_BIN}/aws" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf 'aws %s\n' "$*" >>"${WRAPPER_TEST_COMMAND_LOG}"

if [[ "$*" == *"configure export-credentials --format process"* ]]; then
  if [[ "${WRAPPER_TEST_EXPORT_CREDENTIALS:-success}" == "failure" ]]; then
    exit 1
  fi
  if [[ "${WRAPPER_TEST_STATIC_CREDENTIALS:-false}" == true ]]; then
    printf '%s\n' '{"Version":1,"AccessKeyId":"AKIATESTACCESS","SecretAccessKey":"test-secret-value"}'
  else
    printf '%s\n' '{"Version":1,"AccessKeyId":"ASIATESTACCESS","SecretAccessKey":"test-secret-value","SessionToken":"test-session-token","Expiration":"2099-01-01T00:00:00Z"}'
  fi
  exit 0
fi

if [[ "$*" == *"sts get-caller-identity"* ]]; then
  printf 'sts-env access=%s secret=%s token=%s profile=%s\n' \
    "${AWS_ACCESS_KEY_ID:-unset}" "${AWS_SECRET_ACCESS_KEY:-unset}" \
    "${AWS_SESSION_TOKEN:-unset}" "${AWS_PROFILE:-unset}" >>"${WRAPPER_TEST_COMMAND_LOG}"
  printf '%s\n' "${WRAPPER_TEST_ACTUAL_ACCOUNT:-111122223333}"
  exit 0
fi

printf 'unexpected aws invocation: %s\n' "$*" >&2
exit 2
EOF

cat >"${FAKE_BIN}/terraform" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf 'terraform %s\n' "$*" >>"${WRAPPER_TEST_COMMAND_LOG}"
printf 'terraform-env account=%s access=%s secret=%s token=%s profile=%s\n' \
  "${TF_VAR_expected_aws_account_id:-unset}" "${AWS_ACCESS_KEY_ID:-unset}" \
  "${AWS_SECRET_ACCESS_KEY:-unset}" "${AWS_SESSION_TOKEN:-unset}" \
  "${AWS_PROFILE:-unset}" >>"${WRAPPER_TEST_COMMAND_LOG}"
printf '%s\n' "terraform invoked"
EOF

chmod +x "${FAKE_BIN}/aws" "${FAKE_BIN}/terraform"

run_wrapper() {
  : >"${COMMAND_LOG}"
  : >"${OUTPUT_LOG}"
  env \
    PATH="${FAKE_BIN}:/usr/bin:/bin" \
    WRAPPER_TEST_COMMAND_LOG="${COMMAND_LOG}" \
    WRAPPER_TEST_ACTUAL_ACCOUNT="${WRAPPER_TEST_ACTUAL_ACCOUNT:-111122223333}" \
    WRAPPER_TEST_EXPORT_CREDENTIALS="${WRAPPER_TEST_EXPORT_CREDENTIALS:-success}" \
    WRAPPER_TEST_STATIC_CREDENTIALS="${WRAPPER_TEST_STATIC_CREDENTIALS:-false}" \
    "${REPO_ROOT}/scripts/terraform.sh" "$@" >"${OUTPUT_LOG}" 2>&1
}

expect_failure() {
  local expected=$1
  shift

  if run_wrapper "$@"; then
    printf 'Expected wrapper to fail: %s\n' "${expected}" >&2
    return 1
  fi
  assert_file_contains "${expected}" "${OUTPUT_LOG}"
}

expect_failure "--account-id is required" -- -chdir=infra plan
expect_failure "12-digit AWS account ID" --account-id invalid -- -chdir=infra plan

WRAPPER_TEST_ACTUAL_ACCOUNT=111111111111 \
  expect_failure "authenticated AWS account 111111111111 does not match expected 111122223333" \
  --account-id 111122223333 -- -chdir=infra plan
unset WRAPPER_TEST_ACTUAL_ACCOUNT

run_wrapper --account-id 111122223333 -- -chdir=infra plan -input=false
assert_file_contains "terraform -chdir=infra plan -input=false" "${COMMAND_LOG}"
assert_file_contains "sts-env access=ASIATESTACCESS secret=test-secret-value token=test-session-token profile=unset" "${COMMAND_LOG}"
assert_file_contains "terraform-env account=111122223333 access=ASIATESTACCESS secret=test-secret-value token=test-session-token profile=unset" "${COMMAND_LOG}"

run_wrapper --account-id 111122223333 --profile training -- -chdir=infra validate
assert_file_contains "aws --profile training configure export-credentials --format process" "${COMMAND_LOG}"
assert_file_contains "aws sts get-caller-identity" "${COMMAND_LOG}"
assert_file_excludes "aws --profile training sts get-caller-identity" "${COMMAND_LOG}"
assert_file_contains "terraform-env account=111122223333 access=ASIATESTACCESS secret=test-secret-value token=test-session-token profile=training" "${COMMAND_LOG}"

WRAPPER_TEST_STATIC_CREDENTIALS=true run_wrapper --account-id 111122223333 -- -chdir=infra validate
assert_file_contains "sts-env access=AKIATESTACCESS secret=test-secret-value token=unset" "${COMMAND_LOG}"
assert_file_contains "terraform-env account=111122223333 access=AKIATESTACCESS secret=test-secret-value token=unset" "${COMMAND_LOG}"

WRAPPER_TEST_EXPORT_CREDENTIALS=failure run_wrapper \
  --account-id 111122223333 -- -chdir=infra plan
assert_file_contains "sts-env access=unset secret=unset token=unset profile=unset" "${COMMAND_LOG}"
assert_file_contains "terraform-env account=111122223333 access=unset secret=unset token=unset profile=unset" "${COMMAND_LOG}"

assert_file_excludes "test-secret-value" "${OUTPUT_LOG}"
assert_file_excludes "test-session-token" "${OUTPUT_LOG}"
assert_file_excludes "ASIATESTACCESS" "${OUTPUT_LOG}"

printf '%s\n' "terraform wrapper test passed"
