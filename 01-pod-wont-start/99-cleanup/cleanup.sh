#!/usr/bin/env bash
# Exercise 01 - removes everything the exercise created.
set -uo pipefail

NS=lab01

ctx="$(kubectl config current-context 2>/dev/null || true)"
if [ "$ctx" != "minikube" ]; then
  echo "Abort: current context is '${ctx:-none}', expected 'minikube'." >&2
  exit 1
fi

echo "--- deleting namespace $NS"
kubectl delete namespace "$NS" --ignore-not-found --wait=true --timeout=120s

echo "--- removing temporary files"
rm -fv /tmp/storefront-conf.backup.yaml /tmp/default.conf /tmp/default.conf.orig

echo "--- verifying"
if kubectl get namespace "$NS" >/dev/null 2>&1; then
  echo "FAIL  namespace $NS still exists"
  exit 1
fi
echo "PASS  namespace $NS is gone"
kubectl get pods -A
