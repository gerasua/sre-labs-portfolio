#!/usr/bin/env bash
# cleanup.sh - tears down the INC-0003 lab and stops the cluster.
set -uo pipefail
NS=lab03

echo "== Deleting namespace $NS =="
kubectl delete namespace "$NS" --ignore-not-found --wait=true --timeout=120s

echo
echo "== Namespaces left in the cluster =="
kubectl get ns

echo
echo "== Stopping Minikube =="
minikube stop

echo
echo "== Final state =="
minikube status || true
docker ps --format "table {{.Names}}\t{{.Status}}"
free -h | head -2
