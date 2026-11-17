#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "${SCRIPT_DIR}/lib/aws_session.sh"

usage() {
  printf '%s\n' \
    "Usage: $0 --account-id ID [--profile PROFILE] -- TERRAFORM_ARGS..." >&2
}

account_id=""
profile=""

while (($#)); do
  case "$1" in
    --account-id)
      if (($# < 2)); then
        printf '%s\n' "--account-id is required." >&2
        usage
        exit 2
      fi
      account_id=$2
      shift 2
      ;;
    --profile)
      if (($# < 2)); then
        printf '%s\n' "--profile requires a value." >&2
        usage
        exit 2
      fi
      profile=$2
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      printf 'Unknown wrapper argument: %s\n' "$1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "${account_id}" ]]; then
  printf '%s\n' "--account-id is required." >&2
  usage
  exit 2
fi
if (($# == 0)); then
  printf '%s\n' "Terraform arguments are required after --." >&2
  usage
  exit 2
fi

aws_session_validate_account_id "${account_id}"
aws_session_activate "${profile}"
aws_session_verify_account "${account_id}" "${profile}"

export TF_VAR_expected_aws_account_id="${account_id}"
exec terraform "$@"
