#!/bin/sh

# Keep module docs up to date
terraform-docs md table ../infra/ --no-providers --no-required > ../infra/README.md

for d in $(ls -1 ../infra/modules/)
do
  terraform-docs md table ../infra/modules/$d --no-providers --no-required > ../infra/modules/$d/README.md
done
