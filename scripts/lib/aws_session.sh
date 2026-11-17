#!/usr/bin/env bash

set -euo pipefail

aws_session_validate_account_id() {
  local account_id=$1

  if [[ ! "${account_id}" =~ ^[0-9]{12}$ ]]; then
    printf '%s\n' "Expected a 12-digit AWS account ID." >&2
    return 1
  fi
}

aws_session_cli_args() {
  local profile=${1:-}

  AWS_SESSION_CLI_ARGS=()
  if [[ -n "${profile}" ]]; then
    AWS_SESSION_CLI_ARGS+=(--profile "${profile}")
    export AWS_PROFILE="${profile}"
  fi
}

aws_session_activate() {
  local profile=${1:-}
  local credential_json
  local access_key
  local secret_key
  local session_token

  aws_session_cli_args "${profile}"

  if ! credential_json=$(aws "${AWS_SESSION_CLI_ARGS[@]}" configure export-credentials \
    --format process 2>/dev/null); then
    return 0
  fi

  access_key=$(jq -er '.AccessKeyId' <<<"${credential_json}")
  secret_key=$(jq -er '.SecretAccessKey' <<<"${credential_json}")
  session_token=$(jq -r '.SessionToken // empty' <<<"${credential_json}")

  export AWS_ACCESS_KEY_ID="${access_key}"
  export AWS_SECRET_ACCESS_KEY="${secret_key}"
  if [[ -n "${session_token}" ]]; then
    export AWS_SESSION_TOKEN="${session_token}"
  else
    unset AWS_SESSION_TOKEN
  fi

  # Freeze subsequent CLI calls to the exported credential snapshot. Passing
  # --profile again would let a credential_process or profile file change the
  # identity after the account check.
  AWS_SESSION_CLI_ARGS=()
}

aws_session_verify_account() {
  local expected_account_id=$1
  local actual_account_id

  aws_session_validate_account_id "${expected_account_id}"
  if ! actual_account_id=$(aws "${AWS_SESSION_CLI_ARGS[@]}" sts get-caller-identity \
    --query Account --output text); then
    printf '%s\n' "Unable to verify the authenticated AWS account." >&2
    return 1
  fi

  if [[ "${actual_account_id}" != "${expected_account_id}" ]]; then
    printf 'The authenticated AWS account %s does not match expected %s.\n' \
      "${actual_account_id}" "${expected_account_id}" >&2
    return 1
  fi
}
