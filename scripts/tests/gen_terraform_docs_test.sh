#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/../.." && pwd)
TEST_ROOT=$(mktemp -d "${REPO_ROOT}/.terraform-docs-test.XXXXXX")
COMMAND_LOG="${TEST_ROOT}/commands.log"
FAKE_BIN="${TEST_ROOT}/bin"

cleanup() {
  rm -rf "${TEST_ROOT}"
}
trap cleanup EXIT

mkdir -p "${FAKE_BIN}" "${TEST_ROOT}/scripts" "${TEST_ROOT}/infra/modules/example"
cp "${REPO_ROOT}/scripts/gen_terraform_docs.sh" "${TEST_ROOT}/scripts/"

cat >"${FAKE_BIN}/terraform-docs" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >>"${TERRAFORM_DOCS_TEST_LOG}"
printf '%s\n' "generated documentation"
EOF
chmod +x "${FAKE_BIN}/terraform-docs"

export TERRAFORM_DOCS_TEST_LOG="${COMMAND_LOG}"
(
  cd "${TEST_ROOT}/scripts"
  PATH="${FAKE_BIN}:/usr/bin:/bin" sh ./gen_terraform_docs.sh
)

assert_logged() {
  local expected=$1
  if ! grep -Fxq -- "${expected}" "${COMMAND_LOG}"; then
    printf 'Expected terraform-docs invocation was not run: %s\n' "${expected}" >&2
    cat "${COMMAND_LOG}" >&2
    return 1
  fi
}

assert_logged "markdown table --hide providers --required=false ../infra/"
assert_logged "markdown table --hide providers --required=false ../infra/modules/example"

grep -Fxq "generated documentation" "${TEST_ROOT}/infra/README.md"
grep -Fxq "generated documentation" "${TEST_ROOT}/infra/modules/example/README.md"

printf '%s\n' "terraform-docs generator test passed"
