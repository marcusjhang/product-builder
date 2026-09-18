#!/usr/bin/env bash
source "$(dirname "$0")/../fixtures/lib.sh"
tb_base; tb_profile; tb_layer_plan 'Ready to implement'; tb_layer_plan_two_slices; tb_origin
