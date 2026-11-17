#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "${SCRIPT_DIR}/lib/aws_session.sh"

readonly MARKETPLACE_REGION=us-east-1
readonly KALI_LISTING_ID=prodview-fznsw3f7mq7to
readonly KALI_PRODUCT_ID=804fcc46-63fc-4eb6-85a1-50e66d6c7215
readonly KALI_OFFER_ID=7lgvy7mt78lgoi4lant0znp5h
readonly KALI_PUBLISHER=Kali
readonly KALI_FULFILLMENT=AMAZON_MACHINE_IMAGE
readonly KALI_USAGE_TERM_ID=term-a449225df9df737efb6e504549f70bc90384700b56302109e7a7df74ca572810
readonly KALI_LEGAL_TERM_ID=term-161112f29c1028064c8ded0a895eaaa087ef4557b04d0deedb691d16f89e529c
readonly KALI_SUPPORT_TERM_ID=term-91fc05ac1a6eb423d487144a226475d0b9d63b8bd9c89e473ce00c37ea96ea08

usage() {
  cat <<'EOF'
Usage: accept_kali_marketplace.sh --account-id ID [--profile PROFILE] [--accept [--yes]]

Without --accept, this command only validates and summarizes the pinned free
Kali Linux Marketplace offer. --accept creates a quote and requires an exact
typed confirmation. --yes supplies that final confirmation non-interactively.
EOF
}

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

aws_marketplace() {
  aws "${AWS_SESSION_CLI_ARGS[@]}" "$@"
}

is_past_timestamp() {
  local timestamp=$1
  local timestamp_epoch
  local now_epoch

  [[ -z "${timestamp}" || "${timestamp}" == "null" ]] && return 1
  timestamp_epoch=$(date -u -d "${timestamp}" +%s 2>/dev/null) || return 0
  now_epoch=$(date -u +%s)
  ((timestamp_epoch <= now_epoch))
}

expected_account_id=
profile=
accept=false
assume_yes=false

while (($# > 0)); do
  case "$1" in
    --account-id)
      (($# >= 2)) || fail "--account-id requires a value."
      expected_account_id=$2
      shift 2
      ;;
    --profile)
      (($# >= 2)) || fail "--profile requires a value."
      profile=$2
      shift 2
      ;;
    --accept)
      accept=true
      shift
      ;;
    --yes)
      assume_yes=true
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
aws_session_validate_account_id "${expected_account_id}"
if [[ "${assume_yes}" == true && "${accept}" != true ]]; then
  fail "--yes requires --accept."
fi

aws_session_activate "${profile}"
aws_session_verify_account "${expected_account_id}" "${profile}"

if ! search_json=$(aws_marketplace marketplace-discovery search-listings \
  --region "${MARKETPLACE_REGION}" \
  --search-text "Kali Linux" \
  --output json); then
  fail "Unable to search AWS Marketplace listings."
fi

jq -e --arg listing "${KALI_LISTING_ID}" \
  '.listingSummaries | any(.listingId == $listing)' <<<"${search_json}" >/dev/null \
  || fail "The pinned Kali Marketplace listing is no longer returned by discovery."

if ! listing_json=$(aws_marketplace marketplace-discovery get-listing \
  --region "${MARKETPLACE_REGION}" \
  --listing-id "${KALI_LISTING_ID}" \
  --output json); then
  fail "Unable to inspect the Kali Marketplace listing."
fi

listing_product=$(jq -er '.associatedEntities[0].product.productId' <<<"${listing_json}") \
  || fail "The Kali Marketplace listing has no product identifier."
[[ "${listing_product}" == "${KALI_PRODUCT_ID}" ]] \
  || fail "The Kali Marketplace product changed from the pinned identifier."

listing_offer=$(jq -er '.associatedEntities[0].offer.offerId' <<<"${listing_json}") \
  || fail "The Kali Marketplace listing has no default offer identifier."
[[ "${listing_offer}" == "${KALI_OFFER_ID}" ]] \
  || fail "The Kali Marketplace offer changed from the pinned identifier."

listing_publisher=$(jq -er '.associatedEntities[0].product.manufacturer.displayName' <<<"${listing_json}") \
  || fail "The Kali Marketplace listing has no publisher."
[[ "${listing_publisher}" == "${KALI_PUBLISHER}" ]] \
  || fail "The Kali Marketplace publisher changed from Kali."

jq -e --arg fulfillment "${KALI_FULFILLMENT}" \
  '.fulfillmentOptionSummaries | any(.fulfillmentOptionType == $fulfillment)' \
  <<<"${listing_json}" >/dev/null \
  || fail "The Kali Marketplace listing is no longer fulfilled as an AMI."

jq -e '.pricingModels | any(.pricingModelType == "FREE")' <<<"${listing_json}" >/dev/null \
  || fail "The Kali Marketplace listing no longer advertises a free pricing model."

if ! purchase_options_json=$(aws_marketplace marketplace-discovery list-purchase-options \
  --region "${MARKETPLACE_REGION}" \
  --filters filterType=PRODUCT_ID,filterValues="${KALI_PRODUCT_ID}" \
  --output json); then
  fail "Unable to list Kali Marketplace purchase options."
fi

jq -e --arg offer "${KALI_OFFER_ID}" \
  '.purchaseOptions | any(.purchaseOptionId == $offer and .purchaseOptionType == "OFFER")' \
  <<<"${purchase_options_json}" >/dev/null \
  || fail "The pinned Kali Marketplace offer changed or is unavailable."

if ! offer_json=$(aws_marketplace marketplace-discovery get-offer \
  --region "${MARKETPLACE_REGION}" \
  --offer-id "${KALI_OFFER_ID}" \
  --output json); then
  fail "Unable to inspect the Kali Marketplace offer."
fi

[[ "$(jq -er '.offerId' <<<"${offer_json}")" == "${KALI_OFFER_ID}" ]] \
  || fail "The Kali Marketplace offer changed from the pinned identifier."
[[ "$(jq -er '.associatedEntities[0].product.productId' <<<"${offer_json}")" == "${KALI_PRODUCT_ID}" ]] \
  || fail "The Kali Marketplace product changed from the pinned identifier."
[[ "$(jq -er '.sellerOfRecord.displayName' <<<"${offer_json}")" == "${KALI_PUBLISHER}" ]] \
  || fail "The Kali Marketplace publisher changed from Kali."
[[ "$(jq -er '.pricingModel.pricingModelType' <<<"${offer_json}")" == "FREE" ]] \
  || fail "The Kali Marketplace offer is no longer free."

offer_expiration=$(jq -r '.expirationTime // empty' <<<"${offer_json}")
if is_past_timestamp "${offer_expiration}"; then
  fail "The Kali Marketplace offer has expired."
fi

proposal_id=$(jq -er '.agreementProposalId' <<<"${offer_json}") \
  || fail "The Kali Marketplace offer has no agreement proposal."

if ! terms_json=$(aws_marketplace marketplace-discovery get-offer-terms \
  --region "${MARKETPLACE_REGION}" \
  --offer-id "${KALI_OFFER_ID}" \
  --output json); then
  fail "Unable to inspect the Kali Marketplace offer terms."
fi

term_types=$(jq -r '[.offerTerms[] | keys[0]] | sort | join(",")' <<<"${terms_json}")
[[ "${term_types}" == "legalTerm,supportTerm,usageBasedPricingTerm" ]] || {
  if jq -e '.offerTerms | any(has("renewalTerm"))' <<<"${terms_json}" >/dev/null; then
    fail "The Kali Marketplace offer contains an unexpected renewal term."
  fi
  if ! jq -e '.offerTerms | any(has("legalTerm"))' <<<"${terms_json}" >/dev/null; then
    fail "The required legal term is missing from the Kali Marketplace offer."
  fi
  if ! jq -e '.offerTerms | any(has("supportTerm"))' <<<"${terms_json}" >/dev/null; then
    fail "The required support term is missing from the Kali Marketplace offer."
  fi
  fail "The Kali Marketplace term set changed; refusing acceptance."
}

jq -e '
  ([.offerTerms[] | select(has("usageBasedPricingTerm"))
      | .usageBasedPricingTerm.currencyCode]
    | length == 1 and all(. == "USD"))
  and ([.offerTerms[] | select(has("usageBasedPricingTerm"))
      | .usageBasedPricingTerm.rateCards[].rateCard[].price]
    | length > 0 and all(tonumber == 0))
' <<<"${terms_json}" >/dev/null \
  || fail "The Kali Marketplace offer contains a nonzero Marketplace software charge."

jq -e '.offerTerms | any(.legalTerm?.documents[]?.type == "StandardEula")' \
  <<<"${terms_json}" >/dev/null \
  || fail "The required legal term is missing a Standard EULA."

jq -e --arg usage "${KALI_USAGE_TERM_ID}" --arg legal "${KALI_LEGAL_TERM_ID}" \
  --arg support "${KALI_SUPPORT_TERM_ID}" '
  ([.offerTerms[].usageBasedPricingTerm? | select(.) | .id] == [$usage])
  and ([.offerTerms[].legalTerm? | select(.) | .id] == [$legal])
  and ([.offerTerms[].supportTerm? | select(.) | .id] == [$support])
' <<<"${terms_json}" >/dev/null \
  || fail "The pinned Kali Marketplace term identifiers changed; refusing acceptance."

jq -e '
  [.offerTerms[].legalTerm? | select(.)] as $legal
  | ($legal | length == 1)
  and ($legal[0].documents | length == 1)
  and ($legal[0].documents[0].type == "StandardEula")
  and ($legal[0].documents[0].url | type == "string" and startswith("https://"))
' <<<"${terms_json}" >/dev/null \
  || fail "The Kali Marketplace legal term changed; refusing acceptance."

jq -e '
  [.offerTerms[].supportTerm? | select(.)] as $support
  | ($support | length == 1)
  and ($support[0].refundPolicy == "This is a free product")
' <<<"${terms_json}" >/dev/null \
  || fail "The Kali Marketplace support term changed; refusing acceptance."

requested_terms=$(jq -c '[.offerTerms[] | to_entries[0].value | {id}] | sort_by(.id)' \
  <<<"${terms_json}")
jq -e 'length == 3 and all(.id | type == "string" and length > 0)' \
  <<<"${requested_terms}" >/dev/null \
  || fail "The Kali Marketplace terms do not contain three usable term identifiers."

if ! active_json=$(aws_marketplace marketplace-agreement search-agreements \
  --region "${MARKETPLACE_REGION}" \
  --catalog AWSMarketplace \
  --filters \
    name=PartyType,values=Acceptor \
    name=AgreementType,values=PurchaseAgreement \
    name=OfferId,values="${KALI_OFFER_ID}" \
    name=Status,values=ACTIVE \
  --output json); then
  fail "Unable to inspect existing AWS Marketplace agreements."
fi

printf '%s\n' \
  "Eligible free Kali Marketplace offer" \
  "  Account: ${expected_account_id}" \
  "  Publisher: ${KALI_PUBLISHER}" \
  "  Listing: ${KALI_LISTING_ID}" \
  "  Product: ${KALI_PRODUCT_ID}" \
  "  Offer: ${KALI_OFFER_ID}" \
  "  Fulfillment: ${KALI_FULFILLMENT}" \
  "  Software charge: USD 0" \
  "  Terms: Standard EULA, support, zero-priced usage" \
  "  EULA: $(jq -r '.offerTerms[].legalTerm?.documents[0]?.url // empty' <<<"${terms_json}")" \
  "  Support: $(jq -r '.offerTerms[].supportTerm?.refundPolicy // empty' <<<"${terms_json}")"

if jq -e '.agreementViewSummaries | any(.status == "ACTIVE")' <<<"${active_json}" >/dev/null; then
  printf 'Account %s already has an active Kali Marketplace agreement.\n' "${expected_account_id}"
  exit 0
fi

if [[ "${accept}" != true ]]; then
  printf '%s\n' "Read-only check complete. Re-run with --accept to request an acceptance quote."
  exit 0
fi

if ! quote_json=$(aws_marketplace marketplace-agreement create-agreement-request \
  --region "${MARKETPLACE_REGION}" \
  --intent NEW \
  --agreement-proposal-identifier "${proposal_id}" \
  --requested-terms "${requested_terms}" \
  --output json); then
  fail "Unable to create the Marketplace agreement quote. No agreement was accepted."
fi

quote_expiration=$(jq -r '.expirationTime // empty' <<<"${quote_json}")
if is_past_timestamp "${quote_expiration}"; then
  fail "The Marketplace quote has expired; request a fresh quote."
fi

jq -e '
  def zero: (. == null or . == "null" or ((try tonumber catch false) == 0));
  (.chargeSummary.newAgreementValue | zero)
  and (.chargeSummary.newAgreementValueAfterTax | zero)
  and ([.chargeSummary.expectedCharges[]? | .amount, .amountAfterTax] | all(zero))
  and ([.chargeSummary.itemizedCharges[]? | .incrementalChargeAmount] | all(zero))
  and (.chargeSummary.estimatedTaxes.totalAmount | zero)
' <<<"${quote_json}" >/dev/null \
  || fail "The Marketplace quote contains a nonzero or unrecognized charge."

agreement_request_id=$(jq -er '.agreementRequestId' <<<"${quote_json}") \
  || fail "The Marketplace quote did not return an agreement request ID."

printf '%s\n' \
  "Marketplace quote created:" \
  "  Request: ${agreement_request_id}" \
  "  Quote expires: ${quote_expiration:-not provided}" \
  "  Total software charge: $(jq -r '.chargeSummary.currencyCode // "USD"' <<<"${quote_json}") $(jq -r '.chargeSummary.newAgreementValue // "0"' <<<"${quote_json}")" \
  "  Auto-renewal: disabled (no renewal term)"

confirmation="ACCEPT ${expected_account_id} ${KALI_OFFER_ID}"
if [[ "${assume_yes}" != true ]]; then
  printf 'Type exactly "%s" to accept the Marketplace terms: ' "${confirmation}" >&2
  IFS= read -r entered_confirmation || entered_confirmation=
  [[ "${entered_confirmation}" == "${confirmation}" ]] \
    || fail "Confirmation did not match; no agreement was accepted."
fi

if ! acceptance_json=$(aws_marketplace marketplace-agreement accept-agreement-request \
  --region "${MARKETPLACE_REGION}" \
  --agreement-request-id "${agreement_request_id}" \
  --output json); then
  fail "AWS Marketplace rejected the agreement acceptance."
fi

agreement_id=$(jq -er '.agreementId' <<<"${acceptance_json}") \
  || fail "AWS Marketplace accepted the request without returning an agreement ID."

poll_attempts=${MARKETPLACE_POLL_ATTEMPTS:-12}
poll_interval=${MARKETPLACE_POLL_INTERVAL_SECONDS:-5}
for ((attempt = 1; attempt <= poll_attempts; attempt++)); do
  if active_json=$(aws_marketplace marketplace-agreement search-agreements \
    --region "${MARKETPLACE_REGION}" \
    --catalog AWSMarketplace \
    --filters \
      name=PartyType,values=Acceptor \
      name=AgreementType,values=PurchaseAgreement \
      name=OfferId,values="${KALI_OFFER_ID}" \
      name=Status,values=ACTIVE \
    --output json) \
    && jq -e '.agreementViewSummaries | any(.status == "ACTIVE")' \
      <<<"${active_json}" >/dev/null; then
    printf 'Kali Marketplace agreement is ACTIVE: %s\n' "${agreement_id}"
    exit 0
  fi
  ((attempt < poll_attempts)) && sleep "${poll_interval}"
done

fail "Agreement ${agreement_id} was accepted but did not become ACTIVE before the polling timeout."
