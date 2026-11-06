#!/usr/bin/env bash
# lablog: run a command and append the command, a timestamp and its output to $LOG.
# Usage:  source lablog.sh ; export LOG=/path/to/file.log ; lablog 'kubectl get pods -A'

lablog() {
  if [ -z "${LOG:-}" ]; then
    echo "LOG is not set. Run: export LOG=/path/to/file.log" >&2
    return 1
  fi
  mkdir -p "$(dirname "$LOG")"
  printf '\n$ %s\n# %s\n' "$*" "$(date '+%F %T')" | tee -a "$LOG"
  { eval "$*"; } 2>&1 | tee -a "$LOG"
  return "${PIPESTATUS[0]}"
}
