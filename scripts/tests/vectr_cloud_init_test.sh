#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/../.." && pwd)
source "${SCRIPT_DIR}/testlib.sh"

TEMPLATE="${REPO_ROOT}/infra/modules/vectr/cloud-init.sh.tftpl"
MODULE="${REPO_ROOT}/infra/modules/vectr/main.tf"
ROOT_MODULE="${REPO_ROOT}/infra/main.tf"
TEST_ROOT=$(mktemp -d "${REPO_ROOT}/.vectr-cloud-init-test.XXXXXX")
RENDERED="${TEST_ROOT}/cloud-init.sh"
ROOT_MODULE_BLOCK="${TEST_ROOT}/root-vectr-module.tf"

cleanup() {
  rm -rf "${TEST_ROOT}"
}
trap cleanup EXIT

sed \
  -e 's/${vectr_version}/9.14.1/g' \
  -e 's/${vectr_release_sha256}/8af50476d3c848d37489ab3a0edbe535c72b13f1c75cc96731db58976d9b0e22/g' \
  -e 's#${data_mount_path}#/opt/vectr#g' \
  -e 's#${data_device_name}#/dev/sdf#g' \
  -e 's/${data_volume_id}/vol-0123456789abcdef0/g' \
  -e 's/${data_filesystem_label}/VECTR_DATA/g' \
  -e 's/${zone_name}/thunderdome.lab/g' \
  "${TEMPLATE}" >"${RENDERED}"
sed -n '/^module "vectr" {$/,/^}$/p' "${ROOT_MODULE}" >"${ROOT_MODULE_BLOCK}"

bash -n "${RENDERED}"
assert_file_contains 'sra-vectr-runtime-$VECTR_VERSION-ce.zip' "${RENDERED}"
assert_file_contains '8af50476d3c848d37489ab3a0edbe535c72b13f1c75cc96731db58976d9b0e22' "${RENDERED}"

checksum_line=$(grep -n 'sha256sum --check' "${RENDERED}" | cut -d: -f1)
extract_line=$(grep -n 'unzip ' "${RENDERED}" | tail -n 1 | cut -d: -f1)
if [[ -z "${checksum_line}" || -z "${extract_line}" || "${checksum_line}" -ge "${extract_line}" ]]; then
  printf '%s\n' 'VECTR release checksum verification must precede extraction.' >&2
  exit 1
fi

type_check_line=$(grep -Fn 'filesystem_type=$(blkid' "${RENDERED}" | cut -d: -f1)
format_line=$(grep -n 'mkfs.ext4' "${RENDERED}" | cut -d: -f1)
assert_file_contains 'if [[ -z "$filesystem_type" ]]' "${RENDERED}"
assert_file_contains 'nvme-Amazon_Elastic_Block_Store_$DATA_VOLUME_ID_NORMALIZED' "${RENDERED}"
assert_file_excludes 'nvme-Amazon_Elastic_Block_Store_*' "${RENDERED}"
if [[ -z "${type_check_line}" || -z "${format_line}" || "${type_check_line}" -ge "${format_line}" ]]; then
  printf '%s\n' 'VECTR data volume must be inspected before any filesystem is created.' >&2
  exit 1
fi

assert_file_contains 'if [[ ! -f "$RUNTIME_DIR/.env" ]]' "${RENDERED}"
assert_file_contains 'install -m 0600 "$staging_dir/.env" "$RUNTIME_DIR/.env"' "${RENDERED}"
assert_file_contains 'RELEASE_MARKER=' "${RENDERED}"
assert_file_contains 'openssl rand -hex 32' "${RENDERED}"

assert_file_contains 'RequiresMountsFor=/opt/vectr' "${RENDERED}"
assert_file_contains 'ExecStart=/usr/bin/docker compose' "${RENDERED}"
assert_file_contains 'systemctl enable --now vectr.service' "${RENDERED}"

assert_file_excludes 'VECTR_DATA_KEY' "${MODULE}"
assert_file_excludes 'JWS_KEY' "${MODULE}"
assert_file_excludes 'JWE_KEY' "${MODULE}"
assert_file_excludes 'REDIS_PASSWORD' "${MODULE}"
assert_file_excludes 'POSTGRES_PASSWORD' "${MODULE}"
assert_file_excludes 'resource "aws_eip"' "${MODULE}"
assert_file_contains 'availability_zone    = var.vpc_availability_zone' "${ROOT_MODULE_BLOCK}"
assert_file_contains 'depends_on = [terraform_data.account_guard]' "${ROOT_MODULE_BLOCK}"
assert_file_excludes 'module.vpc]' "${ROOT_MODULE_BLOCK}"

printf '%s\n' "VECTR cloud-init test passed"
