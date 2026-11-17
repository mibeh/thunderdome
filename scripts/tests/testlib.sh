#!/usr/bin/env bash

set -euo pipefail

assert_file_contains() {
  local expected=$1
  local file=$2

  if ! grep -Fq -- "${expected}" "${file}"; then
    printf 'Expected %s to contain: %s\n' "${file}" "${expected}" >&2
    sed -n '1,240p' "${file}" >&2
    return 1
  fi
}

assert_file_excludes() {
  local unexpected=$1
  local file=$2

  if grep -Fq -- "${unexpected}" "${file}"; then
    printf 'Expected %s not to contain: %s\n' "${file}" "${unexpected}" >&2
    sed -n '1,240p' "${file}" >&2
    return 1
  fi
}
