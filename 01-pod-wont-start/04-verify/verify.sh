#!/usr/bin/env bash
# Exercise 01 - end-to-end verification of the storefront service.
set -uo pipefail

NS=lab01
fail=0

check() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "PASS  $desc"
  else
    echo "FAIL  $desc"
    fail=1
  fi
}

ctx="$(kubectl config current-context)"
if [ "$ctx" != "minikube" ]; then
  echo "Abort: current context is '$ctx', expected 'minikube'." >&2
  exit 1
fi

http_body() {
  kubectl -n "$NS" run verify-body --rm -i --restart=Never --image=busybox:1.36 \
    -- wget -qO- -T 5 "http://storefront/healthz" 2>/dev/null
}
http_status() {
  kubectl -n "$NS" run verify-status --rm -i --restart=Never --image=busybox:1.36 \
    -- wget -S -O /dev/null -T 5 "http://storefront/" 2>&1
}

check "rollout completed" kubectl -n "$NS" rollout status deployment/storefront --timeout=60s

ready="$(kubectl -n "$NS" get deployment storefront -o jsonpath='{.status.readyReplicas}')"
check "2 replicas ready (got: ${ready:-0})" test "${ready:-0}" = "2"

restarts="$(kubectl -n "$NS" get pods -l app=storefront \
  -o jsonpath='{range .items[*]}{.status.containerStatuses[0].restartCount}{"\n"}{end}' \
  | awk '{s+=$1} END {print s+0}')"
check "0 container restarts (got: $restarts)" test "$restarts" = "0"

endpoints="$(kubectl -n "$NS" get endpointslices -l kubernetes.io/service-name=storefront \
  -o jsonpath='{.items[*].endpoints[?(@.conditions.ready==true)].addresses[0]}' | wc -w)"
check "service has 2 ready endpoints (got: $endpoints)" test "$endpoints" = "2"

check "nginx -t passes inside the pod" kubectl -n "$NS" exec deployment/storefront -- nginx -t

body="$(http_body || true)"
check "GET /healthz returns 'ok' (got: ${body:0:20})" test "${body:0:2}" = "ok"

status="$(http_status || true)"
check "GET / returns HTTP 200" grep -q "200 OK" <<<"$status"

echo "-----"
if [ "$fail" -eq 0 ]; then
  echo "ALL CHECKS PASSED"
else
  echo "SOME CHECKS FAILED"
  exit 1
fi
