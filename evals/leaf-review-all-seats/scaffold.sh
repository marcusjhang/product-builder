#!/usr/bin/env bash
source "$(dirname "$0")/../fixtures/lib.sh"
tb_base; tb_profile; tb_layer_pathread_test; tb_layer_kitchen_sink_branch; tb_origin
