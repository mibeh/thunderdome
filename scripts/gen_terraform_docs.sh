#!/bin/sh

# Keep module docs up to date
terraform-docs markdown table --hide providers --required=false ../infra/ >../infra/README.md

for module_directory in ../infra/modules/*; do
  [ -d "${module_directory}" ] || continue
  terraform-docs markdown table --hide providers --required=false "${module_directory}" \
    >"${module_directory}/README.md"
done
