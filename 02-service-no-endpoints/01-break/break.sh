#!/usr/bin/env bash
# Exercise 02 - provision the storefront web app in namespace "shop".
set -euo pipefail

# Context guard: never touch a cluster other than the lab one.
if [ "$(kubectl config current-context)" != "minikube" ]; then
  echo "ERROR: kubectl context is not 'minikube'. Aborting." >&2
  exit 1
fi

kubectl create namespace shop --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n shop -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  labels:
    app: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 2
            periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  type: ClusterIP
  selector:
    app: web-app
  ports:
    - name: http
      port: 80
      targetPort: 80
YAML

kubectl rollout status deployment/web -n shop --timeout=180s

cat <<'TICKET'

==================== INCIDENT TICKET ====================
Reported by : storefront team
Namespace   : shop
Symptom     : the "web" app is deployed and its pods look fine,
              but nothing answers at http://web (port 80)
              from inside the cluster.
Your task   : find out why traffic does not arrive and fix it.
==========================================================
TICKET
