#!/usr/bin/env bash
# break.sh - opens incident INC-0003 in the lab cluster.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NS=lab03

kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n "$NS" -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: checkout-api
  labels:
    app: checkout-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: checkout-api
  template:
    metadata:
      labels:
        app: checkout-api
    spec:
      containers:
      - name: api
        image: nginx:1.27-alpine
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 1500m
            memory: 128Mi
          limits:
            cpu: 1500m
            memory: 256Mi
YAML

date '+%F %T' > "$HERE/../02-troubleshoot/incident-start.txt"
echo
cat "$HERE/TICKET.md"
echo
echo "Ticket opened at: $(cat "$HERE/../02-troubleshoot/incident-start.txt")"
