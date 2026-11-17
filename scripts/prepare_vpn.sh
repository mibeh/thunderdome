#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/.." && pwd)
source "${SCRIPT_DIR}/lib/aws_session.sh"

readonly EASYRSA_VERSION=3.2.7
readonly EASYRSA_ARCHIVE="EasyRSA-${EASYRSA_VERSION}.tgz"
readonly EASYRSA_URL="https://github.com/OpenVPN/easy-rsa/releases/download/v${EASYRSA_VERSION}/${EASYRSA_ARCHIVE}"
readonly EASYRSA_SHA256=308743bc9fe871b902d47dbe98d749daff3a05b27531684f02625ce7208d4598
readonly VPN_DIR="${REPO_ROOT}/.vpn-info"

usage() {
  cat <<'EOF'
Usage: prepare_vpn.sh --account-id ID --region REGION [--profile PROFILE] [--rotate]

Generate a private Client VPN CA, server certificate, and client certificate,
then import only the server certificate and key into AWS Certificate Manager.
Existing material is preserved unless --rotate is supplied.
EOF
}

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

expected_account_id=
region=
profile=
rotate=false

while (($# > 0)); do
  case "$1" in
    --account-id)
      (($# >= 2)) || fail "--account-id requires a value."
      expected_account_id=$2
      shift 2
      ;;
    --region)
      (($# >= 2)) || fail "--region requires a value."
      region=$2
      shift 2
      ;;
    --profile)
      (($# >= 2)) || fail "--profile requires a value."
      profile=$2
      shift 2
      ;;
    --rotate)
      rotate=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "${expected_account_id}" ]] || fail "--account-id is required."
[[ -n "${region}" ]] || fail "--region is required."
[[ "${region}" =~ ^[a-z]{2}(-[a-z0-9]+)+-[0-9]+$ ]] || fail "Invalid AWS region: ${region}"

aws_session_validate_account_id "${expected_account_id}"
aws_session_activate "${profile}"
aws_session_verify_account "${expected_account_id}" "${profile}"

targets=(
  "${VPN_DIR}/ca.crt"
  "${VPN_DIR}/server.crt"
  "${VPN_DIR}/server-key"
  "${VPN_DIR}/client.crt"
  "${VPN_DIR}/client-key"
  "${VPN_DIR}/server-certificate-arn"
)

for target in "${targets[@]}"; do
  if [[ -e "${target}" && "${rotate}" != true ]]; then
    fail "VPN material already exists; use --rotate to replace it after a successful ACM import."
  fi
done

mkdir -p "${VPN_DIR}"
chmod 700 "${VPN_DIR}"
umask 077

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/thunderdome-vpn.XXXXXX")
cleanup() {
  rm -rf "${work_dir}"
}
trap cleanup EXIT

archive_path="${work_dir}/${EASYRSA_ARCHIVE}"
if ! curl --fail --location --silent --show-error \
  --output "${archive_path}" "${EASYRSA_URL}"; then
  fail "Unable to download EasyRSA ${EASYRSA_VERSION}."
fi

if ! printf '%s  %s\n' "${EASYRSA_SHA256}" "${archive_path}" \
  | sha256sum --check --status; then
  fail "EasyRSA archive checksum did not match the pinned SHA-256."
fi

tar -xzf "${archive_path}" -C "${work_dir}"
easyrsa_dir="${work_dir}/EasyRSA-${EASYRSA_VERSION}"
[[ -x "${easyrsa_dir}/easyrsa" ]] || fail "The EasyRSA archive did not contain the expected executable."

(
  cd "${easyrsa_dir}"
  ./easyrsa init-pki
  EASYRSA_BATCH=1 EASYRSA_REQ_CN=thunderdome.lab ./easyrsa build-ca nopass
  EASYRSA_BATCH=1 ./easyrsa build-server-full server.thunderdome.lab nopass
  EASYRSA_BATCH=1 ./easyrsa build-client-full client.thunderdome.lab nopass
)

pki_dir="${easyrsa_dir}/pki"
generated_files=(
  "${pki_dir}/ca.crt"
  "${pki_dir}/issued/server.thunderdome.lab.crt"
  "${pki_dir}/private/server.thunderdome.lab.key"
  "${pki_dir}/issued/client.thunderdome.lab.crt"
  "${pki_dir}/private/client.thunderdome.lab.key"
)
for generated_file in "${generated_files[@]}"; do
  [[ -s "${generated_file}" ]] || fail "EasyRSA did not generate ${generated_file##*/}."
done

if ! import_json=$(aws "${AWS_SESSION_CLI_ARGS[@]}" acm import-certificate \
  --region "${region}" \
  --certificate "fileb://${pki_dir}/issued/server.thunderdome.lab.crt" \
  --private-key "fileb://${pki_dir}/private/server.thunderdome.lab.key" \
  --certificate-chain "fileb://${pki_dir}/ca.crt" \
  --output json); then
  fail "AWS Certificate Manager rejected the server certificate import; existing local material was preserved."
fi

certificate_arn=$(jq -er '.CertificateArn' <<<"${import_json}") \
  || fail "AWS Certificate Manager did not return a certificate ARN."

install -m 0644 "${pki_dir}/ca.crt" "${VPN_DIR}/ca.crt"
install -m 0644 "${pki_dir}/issued/server.thunderdome.lab.crt" "${VPN_DIR}/server.crt"
install -m 0600 "${pki_dir}/private/server.thunderdome.lab.key" "${VPN_DIR}/server-key"
install -m 0644 "${pki_dir}/issued/client.thunderdome.lab.crt" "${VPN_DIR}/client.crt"
install -m 0600 "${pki_dir}/private/client.thunderdome.lab.key" "${VPN_DIR}/client-key"
printf '%s\n' "${certificate_arn}" >"${VPN_DIR}/server-certificate-arn"
chmod 0600 "${VPN_DIR}/server-certificate-arn"

printf '%s\n' \
  "VPN certificate material is ready in ${VPN_DIR}." \
  "ACM server certificate: ${certificate_arn}"
