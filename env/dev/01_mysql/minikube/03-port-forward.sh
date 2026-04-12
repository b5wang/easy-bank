#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"

kubectl -n "$K8S_NAMESPACE" get svc "$MYSQL_SERVICE_NAME" >/dev/null 2>&1 || {
    echo "Service $MYSQL_SERVICE_NAME does not exist in namespace $K8S_NAMESPACE." >&2
    echo "Run ./env/dev/01_mysql/minikube/02-deploy-mysql.sh first." >&2
    exit 1
}

# `port-forward` opens a temporary tunnel from localhost to the Kubernetes Service.
# Keep this terminal window open while your local SQL client is connected.
# Re-run this script after `minikube stop/start` or whenever this terminal exits.
echo "Forwarding 127.0.0.1:${MYSQL_LOCAL_PORT} -> ${MYSQL_SERVICE_NAME}:${MYSQL_CONTAINER_PORT}"
kubectl -n "$K8S_NAMESPACE" port-forward "svc/${MYSQL_SERVICE_NAME}" "${MYSQL_LOCAL_PORT}:${MYSQL_CONTAINER_PORT}"
