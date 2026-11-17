# Repository Working Agreement

## Scope and project layout

This repository builds an AWS cyber range. Treat infrastructure changes as security-sensitive and
cost-sensitive even when they are small.

- `infra/` is the Terraform root module. Use `-chdir=infra` or run Terraform from that directory.
- `infra/modules/` contains the VPC, Client VPN, Systems Manager endpoint, Kali, and VECTR modules.
- `scripts/` contains setup, Marketplace, certificate, VPN configuration, Terraform, and
  documentation helpers.
- `infra/README.md` and each `infra/modules/*/README.md` are generated Terraform interface tables.
  The root `README.md` is maintained by hand.

## Compatibility and design constraints

- `scripts/setup.sh` installs Terraform 1.10 or newer and the repository-pinned terraform-docs
  release. Terraform uses AWS provider `~> 6.0`.
- Preserve the range's network segmentation. Review route tables, network ACLs, and security groups
  together before changing CIDRs or traffic rules. Do not broaden public or cross-subnet access
  without an explicit requirement.
- Treat region and CIDR changes as cross-module changes. Check the provider region, availability
  zone, subnet ranges, VPN routes, security-group rules, network ACLs, and local AWS CLI commands
  for hard-coded values.
- Keep feature flags usable in both states. A resource disabled with `count = 0` must not be indexed
  by an unconditional resource, data source, or output. VECTR requires Client VPN.
- Preserve module interfaces unless the task calls for a contract change. Search all module callers
  and generated input/output documentation when changing a variable or output.
- Prefer a Terraform provider resource over `local-exec` when the provider supports the operation.
- Kali uses the official Marketplace AMI directly. VECTR uses Canonical Ubuntu and installs its
  pinned runtime during first boot. Keep image and release selection explicit and checksum-verified.

## Secrets, state, and external effects

- Never commit `.vpn-info/`, private keys, certificates, Terraform state, plan files, credentials,
  generated OpenVPN configurations, populated `.tfvars`, or live AWS identifiers.
- Do not run `scripts/setup.sh` as routine validation. It installs system packages and binaries with
  `sudo`, downloads tools, and initializes Terraform.
- Do not run `scripts/prepare_vpn.sh` or `scripts/export_vpn_config.sh` as routine validation. They
  create or embed private key material, and certificate preparation uploads a certificate to ACM.
- `scripts/accept_kali_marketplace.sh --accept` creates a binding Marketplace agreement. Its default
  mode is read-only; never add `--accept` or `--yes` during routine validation.
- Do not run `terraform apply`, `terraform destroy`, state mutation commands, certificate uploads,
  Marketplace acceptance, or other AWS-changing commands unless the user explicitly requests that
  action and the target account and region are known.
- Use AWS-backed `terraform plan` only when live validation is in scope and the intended account,
  profile, and region are established. Read the plan for replacement, exposure, and cost changes.

## Generated documentation

When Terraform variables or outputs change, regenerate all interface tables with:

```sh
scripts/gen_terraform_docs.sh
```

The helper atomically replaces every Terraform README with the repository-pinned terraform-docs
interface. Review the complete generated diff. Do not hand-edit generated tables unless the task is
repairing the generator or documenting a tool-version limitation.

## Validation

Use Terraform 1.10 or newer and AWS provider 6.x. Run the checks that match the files changed:

```sh
terraform fmt -check -recursive infra
terraform -chdir=infra validate
terraform -chdir=infra test
bash scripts/tests/setup_test.sh
bash scripts/tests/terraform_test.sh
bash scripts/tests/accept_kali_marketplace_test.sh
bash scripts/tests/prepare_vpn_test.sh
bash scripts/tests/export_vpn_config_test.sh
bash scripts/tests/kali_cloud_init_test.sh
bash scripts/tests/vectr_cloud_init_test.sh
bash scripts/tests/gen_terraform_docs_test.sh
git diff --check
```

`terraform validate` requires an initialized working directory. Use `terraform init -backend=false`
only when dependency download is allowed; do not treat an initialization failure as a source-code
failure. Report exactly which checks ran, the tool versions used, and any checks skipped because
tools, credentials, or network access were unavailable.

Before finishing, review the diff for unintended public exposure, hard-coded account or region
values, disabled-feature index errors, secrets, state artifacts, generated-file drift, and unrelated
formatting changes.
