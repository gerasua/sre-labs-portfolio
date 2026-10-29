# lablog: run a command, writing "[timestamp] $ command" plus its output to $LOG.
# Usage: export LOG=<path/to/file.log>; lablog 'kubectl get pods -A'
lablog() {
  if [ -z "${LOG:-}" ]; then
    echo "lablog: set LOG first (export LOG=/path/to/file.log)" >&2
    return 1
  fi
  { printf '\n[%s] $ %s\n' "$(date '+%F %T')" "$*"; eval "$*"; } 2>&1 | tee -a "$LOG"
}
