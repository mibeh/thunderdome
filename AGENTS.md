# Repository Working Agreement

## Scope and project layout

This repository builds an AWS cyber range. Treat infrastructure changes as security-sensitive and
cost-sensitive even when they are small.

- `infra/` is the Terraform root module. Run Terraform commands from this directory.
- `infra/modules/` contains the VPC, Client VPN, SSM endpoint, Kali, and VECTR modules.
- `images/` contains legacy Packer JSON templates for the Kali and VECTR AMIs.
- `scripts/` contains setup, certificate, VPN configuration, and documentation helpers. Several of
  these scripts assume the current directory is `scripts/`.
- `infra/README.md` and each `infra/modules/*/README.md` are generated Terraform interface tables.
  The root `README.md` is maintained by hand.

## Compatibility and design constraints

- `scripts/setup.sh` installs the current Terraform and Packer packages from HashiCorp's APT
  repository. The Terraform configuration still declares AWS provider `~> 2.64` and contains
  legacy syntax. Keep provider and language modernization separate from unrelated changes.
- Preserve the range's network segmentation. Review route tables, network ACLs, and security groups
  together before changing CIDRs or traffic rules. Do not broaden public or cross-subnet access
  without an explicit requirement.
- Treat region and CIDR changes as cross-module changes. Check the provider region, availability
  zone, subnet ranges, VPN routes, security-group rules, network ACLs, and local AWS CLI commands
  for hard-coded values.
- Keep feature flags usable in both states. A resource disabled with `count = 0` must not be indexed
  by an unconditional resource, data source, or output.
- Preserve module interfaces unless the task calls for a contract change. Search all module callers
  and generated input/output documentation when changing a variable or output.
- Prefer a Terraform provider resource over `local-exec` when the pinned provider supports the
  operation. If `local-exec` is necessary, pass the configured region explicitly and make ordering
  and repeat-run behavior clear.
- Keep the Packer templates in legacy JSON format unless migration is the requested work. Do not put
  AWS access keys or secret keys into template variables or committed files.

## Secrets, state, and external effects

- Never commit `.vpn-info/`, private keys, certificates, Terraform state, plan files, credentials,
  or generated OpenVPN configurations. Remember that `.tfvars` files are not ignored by default in
  this repository and may contain sensitive values.
- Do not run `scripts/setup.sh` as routine validation. It installs system packages and binaries with
  `sudo`, downloads tools, and initializes Terraform.
- Do not run `scripts/gen_vpn_certs.sh` or `scripts/gen_vpn_config.sh` as routine validation. They
  create or embed private key material, and certificate generation uploads a certificate to AWS ACM.
- Do not run `terraform apply`, `terraform destroy`, state mutation commands, certificate uploads,
  Packer builds, or other AWS-changing commands unless the user explicitly requests that action and
  the target account and region are known.
- Use `terraform plan` only when AWS-backed validation is in scope and the intended profile and
  region are established. Read the plan for replacement, exposure, and cost-impacting changes.

## Generated documentation

When Terraform variables or outputs change, regenerate the affected tables from the `scripts/`
directory with:

```sh
./gen_terraform_docs.sh
```

The helper overwrites every Terraform README and uses the repository's legacy `terraform-docs`
interface. Review the complete generated diff. Do not hand-edit generated tables unless the task is
specifically repairing the generator or documenting a tool-version limitation.

## Validation

Use the project-compatible Terraform and Packer versions when available. Run the checks that match
the files changed:

```sh
terraform fmt -check -recursive infra
(cd infra && terraform validate)
bash -n scripts/gen_vpn_certs.sh scripts/gen_vpn_config.sh scripts/setup.sh
bash scripts/tests/setup_test.sh
bash scripts/tests/gen_terraform_docs_test.sh
sh -n scripts/gen_terraform_docs.sh
bash -n infra/modules/vectr/vectr_user_data.sh
packer validate -syntax-only images/linux/kali/thunderdome_kali_2019.4.json
packer validate -syntax-only images/linux/vectr/thunderdome_centos_7.json
git diff --check
```

`terraform validate` requires an initialized working directory. Use `terraform init -backend=false`
only when dependency download is allowed; do not treat an initialization failure as a source-code
failure. There is no automated test suite or CI configuration, so report exactly which checks ran,
the tool versions used, and any checks skipped because tools, credentials, or network access were
unavailable.

Before finishing, review the diff for unintended public exposure, hard-coded account or region
values, disabled-feature index errors, secrets, state artifacts, generated-file drift, and unrelated
formatting changes.
