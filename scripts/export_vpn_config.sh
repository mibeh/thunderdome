#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/.." && pwd)
source "${SCRIPT_DIR}/lib/aws_session.sh"

readonly VPN_DIR="${REPO_ROOT}/.vpn-info"
readonly CONFIG_FILE="${VPN_DIR}/config.ovpn"

usage() {
  cat <<'EOF'
Usage: export_vpn_config.sh --account-id ID --region REGION [--profile PROFILE]

Export the deployed AWS Client VPN configuration and atomically embed the
locally generated client certificate and private key.
EOF
}

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

expected_account_id=
region=
profile=

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

[[ -d "${VPN_DIR}" ]] || fail "VPN certificate material is missing; run prepare_vpn.sh first."
[[ -s "${VPN_DIR}/client.crt" ]] || fail "Client certificate is missing; run prepare_vpn.sh first."
[[ -s "${VPN_DIR}/client-key" ]] || fail "Client private key is missing; run prepare_vpn.sh first."

if ! endpoint_id=$(terraform -chdir="${REPO_ROOT}/infra" output -raw client_vpn_endpoint_id 2>/dev/null); then
  fail "Terraform output client_vpn_endpoint_id is unavailable; deploy Client VPN first."
fi
[[ -n "${endpoint_id}" && "${endpoint_id}" != "null" ]] \
  || fail "Terraform output client_vpn_endpoint_id is unavailable; deploy Client VPN first."

if ! base_config=$(aws "${AWS_SESSION_CLI_ARGS[@]}" ec2 export-client-vpn-client-configuration \
  --region "${region}" \
  --client-vpn-endpoint-id "${endpoint_id}" \
  --query ClientConfiguration \
  --output text); then
  fail "Unable to export the AWS Client VPN configuration; existing profile was preserved."
fi
[[ -n "${base_config}" && "${base_config}" != "None" ]] \
  || fail "AWS returned an empty Client VPN configuration; existing profile was preserved."

if grep -Eq '^[[:space:]]*</?(cert|key)>[[:space:]]*$' <<<"${base_config}"; then
  fail "The AWS Client VPN configuration already contains an embedded certificate or key; existing profile was preserved."
fi

temp_config=$(mktemp "${VPN_DIR}/.config.ovpn.XXXXXX")
cleanup() {
  rm -f "${temp_config}"
}
trap cleanup EXIT

{
  printf '%s\n\n' "${base_config}"
  printf '%s\n' '<cert>'
  cat "${VPN_DIR}/client.crt"
  printf '%s\n' '</cert>'
  printf '%s\n' '<key>'
  cat "${VPN_DIR}/client-key"
  printf '%s\n' '</key>'
} >"${temp_config}"
chmod 0600 "${temp_config}"

for marker in '<cert>' '</cert>' '<key>' '</key>'; do
  [[ "$(grep -Fxc -- "${marker}" "${temp_config}")" == 1 ]] \
    || fail "Generated Client VPN profile failed embedded material validation; existing profile was preserved."
done

mv -f "${temp_config}" "${CONFIG_FILE}"
trap - EXIT
chmod 0600 "${CONFIG_FILE}"

printf 'Client VPN profile is ready: %s\n' "${CONFIG_FILE}"
