#!/usr/bin/env bash
# verify.sh - checks that INC-0003 (checkout-api stuck in Pending) is resolved.
set -uo pipefail
NS=lab03
APP=checkout-api
PASS=0
FAIL=0

check() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "[PASS] $desc"; PASS=$((PASS+1))
  else
    echo "[FAIL] $desc"; FAIL=$((FAIL+1))
  fi
}

c_ready()     { [ "$(kubectl get deploy "$APP" -n "$NS" -o jsonpath='{.status.readyReplicas}')" = "3" ]; }
c_nopending() { [ -z "$(kubectl get pods -n "$NS" --field-selector=status.phase=Pending -o name)" ]; }
c_threepods() { [ "$(kubectl get pods -n "$NS" -l app="$APP" --no-headers | wc -l)" = "3" ]; }
c_rollout()   { kubectl rollout status deploy/"$APP" -n "$NS" --timeout=60s; }
c_request()   { [ "$(kubectl get deploy "$APP" -n "$NS" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')" = "100m" ]; }
c_nodepct()   { local p; p=$(kubectl describe node minikube | awk '/^  cpu /{gsub(/[()%]/,"",$3); print $3}'); [ -n "$p" ] && [ "$p" -lt 80 ]; }
c_restarts()  { local s; s=$(kubectl get pods -n "$NS" -l app="$APP" -o jsonpath='{.items[*].status.containerStatuses[0].restartCount}' | tr ' ' '\n' | awk '{s+=$1} END{print s+0}'); [ "$s" = "0" ]; }
c_http()      { local out; out=$(kubectl exec -n "$NS" deploy/"$APP" -- wget -qO- -T 5 http://localhost/ 2>/dev/null); [[ "$out" == *"Welcome to nginx"* ]]; }

check "Deployment reports 3 ready replicas"            c_ready
check "No pod is in Pending"                           c_nopending
check "Exactly 3 pods exist (old pod fully terminated)" c_threepods
check "Rollout is complete"                            c_rollout
check "CPU request per replica is 100m"                c_request
check "Node CPU reserved is below 80%"                 c_nodepct
check "No container restarts"                          c_restarts
check "Application answers HTTP inside the pod"        c_http

echo
echo "Result: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
