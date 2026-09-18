#!/usr/bin/env bash
source "$(dirname "$0")/../fixtures/lib.sh"
calcom_base; calcom_pr_branch 1 pr-embed-guard; git checkout -q main
