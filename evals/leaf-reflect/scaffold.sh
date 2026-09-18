#!/usr/bin/env bash
source "$(dirname "$0")/../fixtures/lib.sh"
tb_base; tb_profile; tb_layer_plan 'Ready to implement'; tb_layer_p1_merged; tb_plan_status keyboard-archive Shipped; tb_origin
