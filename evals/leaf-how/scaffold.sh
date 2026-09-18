#!/usr/bin/env bash
source "$(dirname "$0")/../fixtures/lib.sh"
tb_base; tb_profile; tb_layer_shipped_snooze; tb_layer_vendored_dep; tb_origin
