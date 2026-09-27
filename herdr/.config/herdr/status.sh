#!/bin/sh
# herdr tab-bar status: active task · scratch items · review-queue items.
# Runs every few seconds on the herdr server, so keep it cheap and quiet:
# every probe tolerates a missing tool and prints nothing rather than errors.

task_desc=$(task rc.verbose=nothing rc.hooks=off +ACTIVE _unique description 2>/dev/null | head -n 1)
scratch_n=$(scratch -c 2>/dev/null)
review_n=$(find "$HOME/clients" -maxdepth 4 -path '*/review-queue/*.md' ! -name '.*' 2>/dev/null | wc -l | tr -d ' ')

out=""
[ -n "$task_desc" ] && out="▶ $(printf '%s' "$task_desc" | cut -c1-28 | sed "s/ *$//")"
[ "${scratch_n:-0}" -gt 0 ] 2>/dev/null && out="${out:+$out · }✎ $scratch_n"
[ "${review_n:-0}" -gt 0 ] 2>/dev/null && out="${out:+$out · }⚑ $review_n"
printf '%s\n' "$out"
