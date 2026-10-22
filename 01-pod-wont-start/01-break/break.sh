#!/usr/bin/env bash
# Exercise 01 - deploys the storefront app into namespace lab01.
set -euo pipefail

NS=lab01
DIR="$(cd "$(dirname "$0")" && pwd)"

ctx="$(kubectl config current-context)"
if [ "$ctx" != "minikube" ]; then
  echo "Abort: current context is '$ctx', expected 'minikube'." >&2
  exit 1
fi

kubectl apply -f "$DIR/storefront.yaml"
kubectl -n "$NS" rollout status deployment/storefront --timeout=45s || true
echo "--- state after deploy"
kubectl -n "$NS" get pods
