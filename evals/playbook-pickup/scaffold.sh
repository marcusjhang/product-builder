#!/usr/bin/env bash
source "$(dirname "$0")/../fixtures/lib.sh"
tb_base; tb_profile; tb_layer_plan 'Ready to implement'; tb_plan_status keyboard-archive Implementing; tb_layer_slice_branch; tb_origin; git checkout -q keyboard-archive/p1-archive-button
