#!/usr/bin/env bash
# Exercise 02 - verify that Service "web" routes traffic to its pods.
# Exit code: 0 if every check passes, 1 otherwise.
set -uo pipefail

NS=shop
SVC=web
PASS=0
FAIL=0

check() {  # usage: check "description" function_name
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    printf '[PASS] %s\n' "$desc"; PASS=$((PASS + 1))
  else
    printf '[FAIL] %s\n' "$desc"; FAIL=$((FAIL + 1))
  fi
}

endpoint_addrs() {
  kubectl get endpointslices -n "$NS" -l "kubernetes.io/service-name=$SVC" \
    -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}'
}
pod_ips() {
  kubectl get pods -n "$NS" -l app=web \
    -o jsonpath='{range .items[*]}{.status.podIP}{"\n"}{end}'
}

ctx_ok()          { [ "$(kubectl config current-context)" = "minikube" ]; }
ns_ok()           { kubectl get ns "$NS"; }
deploy_ready()    { [ "$(kubectl get deploy web -n "$NS" -o jsonpath='{.status.readyReplicas}')" = "2" ]; }
selector_match()  {
  local s p
  s=$(kubectl get svc "$SVC" -n "$NS" -o jsonpath='{.spec.selector.app}')
  p=$(kubectl get deploy web -n "$NS" -o jsonpath='{.spec.template.metadata.labels.app}')
  [ -n "$s" ] && [ "$s" = "$p" ]
}
endpoints_two()   { [ "$(endpoint_addrs | grep -c .)" -eq 2 ]; }
endpoints_pods()  { [ "$(endpoint_addrs | sort)" = "$(pod_ips | sort)" ]; }
http_ok()         {
  kubectl run "verify-probe-$$" -n "$NS" --rm -i --restart=Never \
    --image=busybox:1.36 -- wget -qO- -T 3 "http://$SVC" 2>/dev/null \
    | grep "Welcome to nginx" >/dev/null
}

check "kubectl context is minikube"                     ctx_ok
check "namespace $NS exists"                            ns_ok
check "deployment web has 2/2 replicas ready"           deploy_ready
check "service selector matches the pod template label" selector_match
check "service has exactly 2 endpoints"                 endpoints_two
check "endpoints are exactly the pod IPs"               endpoints_pods
check "HTTP request to http://$SVC returns the app"     http_ok

printf '\nResult: %d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
