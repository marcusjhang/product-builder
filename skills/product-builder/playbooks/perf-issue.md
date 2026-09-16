### Perf issue

**You own the number. Baseline first, one change at a time, interleaved measurement.**

1. Metric, unit, and a probe (a command or script a reviewer can rerun).
2. Baseline on trunk, recorded first.
3. Trace with the profile's tools.
4. Hypothesis, then one change.
5. Interleaved re-measure, trunk and head.
6. The rule with the number; if trunk lacks the feature, an absolute budget instead of a ratio.
7. **product-builder-review**, then `playbooks/opening-a-pr.md` with `before → after` and the probe path.

**Reply:** the metric and unit; baseline and after, interleaved; the probe a reviewer can rerun; what changed and why it helped; the PR URL.
