#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
temporary_readme=

cleanup() {
  if [ -n "${temporary_readme}" ]; then
    rm -f -- "${temporary_readme}"
  fi
}
trap cleanup EXIT HUP INT TERM

generate_readme() {
  directory=$1
  temporary_readme=$(mktemp "${directory}/.README.md.XXXXXX")

  terraform-docs markdown table --hide providers --required=false "${directory}" \
    >"${temporary_readme}"
  mv -f -- "${temporary_readme}" "${directory}/README.md"
  temporary_readme=
}

cd "${SCRIPT_DIR}"
generate_readme ../infra

for module_directory in ../infra/modules/*; do
  [ -d "${module_directory}" ] || continue
  generate_readme "${module_directory}"
done
