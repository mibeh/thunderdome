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

mkdir -p \
  "${FAKE_BIN}" \
  "${TEST_ROOT}/scripts" \
  "${TEST_ROOT}/infra/modules/alpha" \
  "${TEST_ROOT}/infra/modules/client-vpn"
cp "${REPO_ROOT}/scripts/gen_terraform_docs.sh" "${TEST_ROOT}/scripts/"
printf '%s\n' "old documentation" >"${TEST_ROOT}/infra/README.md"
printf '%s\n' "old documentation" >"${TEST_ROOT}/infra/modules/alpha/README.md"
printf '%s\n' "old documentation" >"${TEST_ROOT}/infra/modules/client-vpn/README.md"

cat >"${FAKE_BIN}/terraform-docs" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

directory=${!#}
readme="${directory%/}/README.md"

printf '%s\n' "$*" >>"${TERRAFORM_DOCS_TEST_LOG}"
if ! grep -Fxq -- "old documentation" "${readme}"; then
  printf 'README was modified before terraform-docs completed: %s\n' "${readme}" >&2
  exit 91
fi

printf 'generated documentation for %s\n' "${directory}"
EOF
chmod +x "${FAKE_BIN}/terraform-docs"

export TERRAFORM_DOCS_TEST_LOG="${COMMAND_LOG}"
(
  cd "${TEST_ROOT}/scripts"
  PATH="${FAKE_BIN}:/usr/bin:/bin" sh ./gen_terraform_docs.sh
)

assert_logged_once() {
  local expected=$1
  local count

  count=$(grep -Fxc -- "${expected}" "${COMMAND_LOG}" || true)
  if [[ "${count}" != "1" ]]; then
    printf 'Expected one terraform-docs invocation, found %s: %s\n' "${count}" "${expected}" >&2
    cat "${COMMAND_LOG}" >&2
    return 1
  fi
}

assert_logged_once "markdown table --hide providers --required=false ../infra"
assert_logged_once "markdown table --hide providers --required=false ../infra/modules/alpha"
assert_logged_once "markdown table --hide providers --required=false ../infra/modules/client-vpn"

[[ $(wc -l <"${COMMAND_LOG}") -eq 3 ]]
grep -Fxq "generated documentation for ../infra" "${TEST_ROOT}/infra/README.md"
grep -Fxq "generated documentation for ../infra/modules/alpha" "${TEST_ROOT}/infra/modules/alpha/README.md"
grep -Fxq "generated documentation for ../infra/modules/client-vpn" "${TEST_ROOT}/infra/modules/client-vpn/README.md"

if find "${TEST_ROOT}/infra" -name '.README.md.*' -print -quit | grep -q .; then
  printf '%s\n' "Temporary README files were not cleaned up." >&2
  exit 1
fi

printf '%s\n' "terraform-docs generator test passed"
