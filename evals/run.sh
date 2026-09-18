#!/usr/bin/env bash
# Run the eval suite with the environment the native runner's sandbox needs on this machine, then save a summary.
# Usage: evals/run.sh [claude plugin eval options...]   e.g. evals/run.sh --case 'playbook-*' --tag tier2 -j 4
# Every run's aggregate JSON and a Markdown summary are copied to docs/evals/runs/<timestamp>/ so results are kept.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EH="${PB_EVAL_HOME:-$HOME/.pb-eval-home}"
# A clean HOME that links only what Claude Code needs: the runner's sandbox refuses to start when the real home
# holds a credential store it cannot exclude (a Docker cli-plugins directory with symlinks, an unparseable key file).
mkdir -p "$EH/bin"
for l in .claude .claude.json Library; do [ -e "$HOME/$l" ] && [ ! -e "$EH/$l" ] && ln -s "$HOME/$l" "$EH/$l" || true; done
# /usr/bin/git is an xcrun shim that needs a cache the sandbox denies; put a real git first on PATH.
for g in git git-upload-pack git-receive-pack git-upload-archive; do
  if [ -x "/Library/Developer/CommandLineTools/usr/bin/$g" ]; then
    printf '#!/bin/sh\nexec /Library/Developer/CommandLineTools/usr/bin/%s "$@"\n' "$g" > "$EH/bin/$g"; chmod +x "$EH/bin/$g"
  fi
done
STAMP="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
OUT="$ROOT/docs/evals/runs/$STAMP"; mkdir -p "$OUT"
cd "$ROOT"
set +e
env -u GOOGLE_APPLICATION_CREDENTIALS HOME="$EH" PATH="$EH/bin:$PATH" \
  claude plugin eval . --scaffold --trust-plugin --allow-tools Bash Write Edit --no-publish --keep-temp \
  --json "$OUT/aggregate-result.json" "$@" 2>&1 | tee "$OUT/run.log"
status=${PIPESTATUS[0]}
set -e
python3 "$ROOT/evals/summarize.py" "$OUT/aggregate-result.json" > "$OUT/summary.md" 2>/dev/null || true
echo "saved: $OUT (exit $status)"
exit $status
