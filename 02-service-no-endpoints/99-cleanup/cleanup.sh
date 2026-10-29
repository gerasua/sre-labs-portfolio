#!/usr/bin/env bash
# Exercise 02 - remove everything the exercise created in the cluster.
# Idempotent: safe to run more than once.
set -euo pipefail

NS=shop

# Context guard: never delete anything outside the lab cluster.
if [ "$(kubectl config current-context)" != "minikube" ]; then
  echo "ERROR: kubectl context is not 'minikube'. Aborting." >&2
  exit 1
fi

echo "Deleting namespace $NS (Deployment, Service and pods go with it)..."
kubectl delete namespace "$NS" --ignore-not-found --wait=true --timeout=120s

if kubectl get namespace "$NS" >/dev/null 2>&1; then
  echo "FAIL: namespace $NS still exists." >&2
  exit 1
fi
echo "OK: namespace $NS is gone."
