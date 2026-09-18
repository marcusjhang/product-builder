#!/usr/bin/env bash
source "$(dirname "$0")/../fixtures/lib.sh"
tb_base; tb_profile; sed -i '' 's/^Model: none/Model: typesafe\/jev-latest/' .product-builder/profile.md; git add -A; git -c user.name=f -c user.email=f@e commit -q -m judge; tb_origin
