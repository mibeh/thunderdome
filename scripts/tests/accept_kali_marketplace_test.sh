#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/../.." && pwd)
source "${SCRIPT_DIR}/testlib.sh"

TEST_ROOT=$(mktemp -d "${REPO_ROOT}/.marketplace-test.XXXXXX")
FAKE_BIN="${TEST_ROOT}/bin"
COMMAND_LOG="${TEST_ROOT}/commands.log"
OUTPUT_LOG="${TEST_ROOT}/output.log"
STATE_DIR="${TEST_ROOT}/state"

cleanup() {
  rm -rf "${TEST_ROOT}"
}
trap cleanup EXIT

mkdir -p "${FAKE_BIN}" "${STATE_DIR}"

cat >"${FAKE_BIN}/aws" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf 'aws %s\n' "$*" >>"${MARKETPLACE_TEST_COMMAND_LOG}"

args=("$@")
if [[ "${args[0]:-}" == "--profile" ]]; then
  args=("${args[@]:2}")
fi

service=${args[0]:-}
operation=${args[1]:-}
scenario=${MARKETPLACE_TEST_SCENARIO:-eligible}

if [[ "${service} ${operation}" == "configure export-credentials" ]]; then
  printf '%s\n' '{"Version":1,"AccessKeyId":"ASIATESTACCESS","SecretAccessKey":"test-secret","SessionToken":"test-token"}'
  exit 0
fi

if [[ "${service} ${operation}" == "sts get-caller-identity" ]]; then
  printf '%s\n' "${MARKETPLACE_TEST_ACCOUNT:-111122223333}"
  exit 0
fi

case "${service} ${operation}" in
  "marketplace-discovery search-listings")
    printf '%s\n' '{"listingSummaries":[{"listingId":"prodview-fznsw3f7mq7to","listingName":"Kali Linux"}]}'
    ;;
  "marketplace-discovery get-listing")
    publisher=Kali
    product=804fcc46-63fc-4eb6-85a1-50e66d6c7215
    offer=7lgvy7mt78lgoi4lant0znp5h
    fulfillment=AMAZON_MACHINE_IMAGE
    [[ "${scenario}" == "wrong_publisher" ]] && publisher=Impostor
    [[ "${scenario}" == "wrong_product" ]] && product=00000000-0000-0000-0000-000000000000
    [[ "${scenario}" == "wrong_offer" ]] && offer=wrong-offer-id
    jq -n \
      --arg publisher "${publisher}" \
      --arg product "${product}" \
      --arg offer "${offer}" \
      --arg fulfillment "${fulfillment}" \
      '{listingId:"prodview-fznsw3f7mq7to",listingName:"Kali Linux",catalog:"AWSMarketplace",fulfillmentOptionSummaries:[{fulfillmentOptionType:$fulfillment,displayName:"Amazon Machine Image"}],pricingModels:[{pricingModelType:"FREE",displayName:"Free"}],associatedEntities:[{product:{productId:$product,productName:"Kali Linux",manufacturer:{displayName:$publisher,sellerProfileId:"seller-kali"}},offer:{offerId:$offer,sellerOfRecord:{displayName:$publisher,sellerProfileId:"seller-kali"}}}]}'
    ;;
  "marketplace-discovery list-purchase-options")
    offer=7lgvy7mt78lgoi4lant0znp5h
    [[ "${scenario}" == "wrong_offer" ]] && offer=wrong-offer-id
    jq -n --arg offer "${offer}" '{purchaseOptions:[{purchaseOptionId:$offer,catalog:"AWSMarketplace",purchaseOptionType:"OFFER",sellerOfRecord:{displayName:"Kali",sellerProfileId:"seller-kali"}}]}'
    ;;
  "marketplace-discovery get-offer")
    pricing=FREE
    publisher=Kali
    product=804fcc46-63fc-4eb6-85a1-50e66d6c7215
    expiration=null
    [[ "${scenario}" == "non_free" ]] && pricing=USAGE
    [[ "${scenario}" == "wrong_publisher" ]] && publisher=Impostor
    [[ "${scenario}" == "wrong_product" ]] && product=00000000-0000-0000-0000-000000000000
    jq -n \
      --arg pricing "${pricing}" \
      --arg publisher "${publisher}" \
      --arg product "${product}" \
      --argjson expiration "${expiration}" \
      '{offerId:"7lgvy7mt78lgoi4lant0znp5h",catalog:"AWSMarketplace",sellerOfRecord:{displayName:$publisher,sellerProfileId:"seller-kali"},associatedEntities:[{product:{productId:$product,productName:"Kali Linux",manufacturer:{displayName:$publisher,sellerProfileId:"seller-kali"}}}],agreementProposalId:"at-testproposal",pricingModel:{pricingModelType:$pricing,displayName:$pricing},expirationTime:$expiration}'
    ;;
  "marketplace-discovery get-offer-terms")
    usage_price=0
    include_legal=true
    include_renewal=false
    [[ "${scenario}" == "changed_charge" ]] && usage_price=0.01
    [[ "${scenario}" == "missing_term" ]] && include_legal=false
    [[ "${scenario}" == "changed_renewal" ]] && include_renewal=true
    support_policy='This is a free product'
    [[ "${scenario}" == "changed_support" ]] && support_policy='No refunds'
    extra_document=false
    [[ "${scenario}" == "extra_legal_document" ]] && extra_document=true
    jq -n \
      --arg usage_price "${usage_price}" \
      --argjson include_legal "${include_legal}" \
      --argjson include_renewal "${include_renewal}" \
      --arg support_policy "${support_policy}" \
      --argjson extra_document "${extra_document}" \
      '{offerTerms:([ {usageBasedPricingTerm:{id:"term-a449225df9df737efb6e504549f70bc90384700b56302109e7a7df74ca572810",type:"UsageBasedPricingTerm",currencyCode:"USD",rateCards:[{rateCard:[{dimensionKey:"t3a.medium",unit:"Hrs",price:$usage_price}]}]}}, {supportTerm:{id:"term-91fc05ac1a6eb423d487144a226475d0b9d63b8bd9c89e473ce00c37ea96ea08",type:"SupportTerm",refundPolicy:$support_policy}} ] + (if $include_legal then [{legalTerm:{id:"term-161112f29c1028064c8ded0a895eaaa087ef4557b04d0deedb691d16f89e529c",type:"LegalTerm",documents:([{type:"StandardEula",url:"https://example.invalid/eula"}] + (if $extra_document then [{type:"CustomEula",url:"https://example.invalid/custom"}] else [] end))}}] else [] end) + (if $include_renewal then [{renewalTerm:{id:"term-renewal",type:"RenewalTerm",configuration:{enableAutoRenew:true}}}] else [] end))}'
    ;;
  "marketplace-agreement search-agreements")
    if [[ "${scenario}" == "active" ]] || [[ -f "${MARKETPLACE_TEST_STATE_DIR}/accepted" ]]; then
      printf '%s\n' '{"agreementViewSummaries":[{"agreementId":"ag-active","offerId":"7lgvy7mt78lgoi4lant0znp5h","status":"ACTIVE"}]}'
    else
      printf '%s\n' '{"agreementViewSummaries":[]}'
    fi
    ;;
  "marketplace-agreement create-agreement-request")
    [[ "${scenario}" == "create_rejected" ]] && exit 42
    if [[ "${scenario}" == "quote_expired" ]]; then
      printf '%s\n' '{"agreementRequestId":"ar-testrequest","expirationTime":"2000-01-01T00:00:00Z","chargeSummary":{"currencyCode":"USD","newAgreementValue":"0","expectedCharges":[],"itemizedCharges":[]}}'
    elif [[ "${scenario}" == "quote_string_null" ]]; then
      printf '%s\n' '{"agreementRequestId":"ar-testrequest","chargeSummary":{"currencyCode":"USD","newAgreementValue":"0","expectedCharges":[{"amount":"null"}],"itemizedCharges":[]}}'
    else
      printf '%s\n' '{"agreementRequestId":"ar-testrequest","chargeSummary":{"currencyCode":"USD","newAgreementValue":"0","expectedCharges":[{"id":"charge-1","amount":"0"}],"itemizedCharges":[{"dimensionKey":"t3a.medium","incrementalChargeAmount":"0"}]}}'
    fi
    ;;
  "marketplace-agreement accept-agreement-request")
    [[ "${scenario}" == "accept_rejected" ]] && exit 43
    : >"${MARKETPLACE_TEST_STATE_DIR}/accepted"
    printf '%s\n' '{"agreementId":"ag-testagreement"}'
    ;;
  *)
    printf 'unexpected aws invocation: %s\n' "$*" >&2
    exit 2
    ;;
esac
EOF

chmod +x "${FAKE_BIN}/aws"

run_marketplace() {
  local scenario=$1
  shift

  : >"${COMMAND_LOG}"
  : >"${OUTPUT_LOG}"
  rm -f "${STATE_DIR}/accepted"
  env \
    PATH="${FAKE_BIN}:/usr/bin:/bin" \
    MARKETPLACE_TEST_COMMAND_LOG="${COMMAND_LOG}" \
    MARKETPLACE_TEST_STATE_DIR="${STATE_DIR}" \
    MARKETPLACE_TEST_SCENARIO="${scenario}" \
    MARKETPLACE_TEST_ACCOUNT="${MARKETPLACE_TEST_ACCOUNT:-111122223333}" \
    MARKETPLACE_POLL_INTERVAL_SECONDS=0 \
    MARKETPLACE_POLL_ATTEMPTS=3 \
    "${REPO_ROOT}/scripts/accept_kali_marketplace.sh" "$@" >"${OUTPUT_LOG}" 2>&1
}

expect_failure() {
  local scenario=$1
  local expected=$2
  shift 2

  if run_marketplace "${scenario}" "$@"; then
    printf 'Expected Marketplace helper to fail for %s\n' "${scenario}" >&2
    return 1
  fi
  assert_file_contains "${expected}" "${OUTPUT_LOG}"
}

if run_marketplace eligible --account-id 111122223333 --yes; then
  printf '%s\n' 'Expected --yes without --accept to fail.' >&2
  exit 1
fi
assert_file_contains "--yes requires --accept" "${OUTPUT_LOG}"
[[ ! -s "${COMMAND_LOG}" ]]

MARKETPLACE_TEST_ACCOUNT=111111111111 \
  expect_failure eligible "does not match expected 111122223333" --account-id 111122223333
unset MARKETPLACE_TEST_ACCOUNT
assert_file_excludes "marketplace-discovery" "${COMMAND_LOG}"

if ! run_marketplace active --account-id 111122223333; then
  sed -n '1,240p' "${OUTPUT_LOG}" >&2
  exit 1
fi
assert_file_contains "already has an active Kali Marketplace agreement" "${OUTPUT_LOG}"
assert_file_excludes "create-agreement-request" "${COMMAND_LOG}"
assert_file_excludes "accept-agreement-request" "${COMMAND_LOG}"

if ! run_marketplace eligible --account-id 111122223333; then
  sed -n '1,240p' "${OUTPUT_LOG}" >&2
  exit 1
fi
assert_file_contains "Eligible free Kali Marketplace offer" "${OUTPUT_LOG}"
assert_file_contains "Account: 111122223333" "${OUTPUT_LOG}"
assert_file_contains "Fulfillment: AMAZON_MACHINE_IMAGE" "${OUTPUT_LOG}"
assert_file_excludes "create-agreement-request" "${COMMAND_LOG}"
assert_file_excludes "accept-agreement-request" "${COMMAND_LOG}"

expect_failure wrong_publisher "publisher changed" --account-id 111122223333
expect_failure wrong_product "product changed" --account-id 111122223333
expect_failure wrong_offer "offer changed" --account-id 111122223333
expect_failure non_free "no longer free" --account-id 111122223333
expect_failure missing_term "required legal term is missing" --account-id 111122223333
expect_failure changed_renewal "unexpected renewal term" --account-id 111122223333
expect_failure changed_charge "nonzero Marketplace software charge" --account-id 111122223333
expect_failure changed_support "support term changed" --account-id 111122223333
expect_failure extra_legal_document "legal term changed" --account-id 111122223333

expect_failure eligible "Confirmation did not match" --account-id 111122223333 --accept <<<"no"
assert_file_contains "create-agreement-request" "${COMMAND_LOG}"
assert_file_excludes "accept-agreement-request" "${COMMAND_LOG}"

expect_failure quote_string_null "Confirmation did not match" --account-id 111122223333 --accept <<<"no"
assert_file_excludes "accept-agreement-request" "${COMMAND_LOG}"

expect_failure quote_expired "Marketplace quote has expired" --account-id 111122223333 --accept --yes
assert_file_excludes "accept-agreement-request" "${COMMAND_LOG}"

expect_failure create_rejected "Unable to create the Marketplace agreement quote" --account-id 111122223333 --accept --yes
expect_failure accept_rejected "Marketplace rejected the agreement acceptance" --account-id 111122223333 --accept --yes

if ! run_marketplace eligible --account-id 111122223333 --profile training --accept --yes; then
  sed -n '1,240p' "${OUTPUT_LOG}" >&2
  exit 1
fi
assert_file_contains "Kali Marketplace agreement is ACTIVE" "${OUTPUT_LOG}"
assert_file_contains "aws marketplace-discovery search-listings" "${COMMAND_LOG}"
assert_file_excludes "aws --profile training marketplace-discovery search-listings" "${COMMAND_LOG}"
assert_file_contains "--listing-id prodview-fznsw3f7mq7to" "${COMMAND_LOG}"
assert_file_contains "filterType=PRODUCT_ID,filterValues=804fcc46-63fc-4eb6-85a1-50e66d6c7215" "${COMMAND_LOG}"
assert_file_contains "--offer-id 7lgvy7mt78lgoi4lant0znp5h" "${COMMAND_LOG}"
assert_file_contains "--agreement-proposal-identifier at-testproposal" "${COMMAND_LOG}"
assert_file_contains '"id":"term-a449225df9df737efb6e504549f70bc90384700b56302109e7a7df74ca572810"' "${COMMAND_LOG}"
assert_file_contains '"id":"term-161112f29c1028064c8ded0a895eaaa087ef4557b04d0deedb691d16f89e529c"' "${COMMAND_LOG}"
assert_file_contains '"id":"term-91fc05ac1a6eb423d487144a226475d0b9d63b8bd9c89e473ce00c37ea96ea08"' "${COMMAND_LOG}"
assert_file_contains "accept-agreement-request --region us-east-1 --agreement-request-id ar-testrequest" "${COMMAND_LOG}"

printf '%s\n' "Kali Marketplace acceptance test passed"
