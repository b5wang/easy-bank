#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"

kubectl apply -f "$K8S_DIR/namespace.yaml"

kubectl -n "$K8S_NAMESPACE" get secret "$MYSQL_SECRET_NAME" >/dev/null 2>&1 || {
    echo "Secret $MYSQL_SECRET_NAME does not exist in namespace $K8S_NAMESPACE." >&2
    echo "Run ./env/dev/01_mysql/minikube/01-create-secret.sh first." >&2
    exit 1
}

kubectl apply -f "$K8S_DIR/mysql-pvc.yaml"
kubectl apply -f "$K8S_DIR/mysql-deployment.yaml"
kubectl apply -f "$K8S_DIR/mysql-service.yaml"

kubectl -n "$K8S_NAMESPACE" rollout status deployment/"$MYSQL_DEPLOYMENT_NAME" --timeout=300s

echo "Cluster MySQL endpoint: ${MYSQL_SERVICE_NAME}.${K8S_NAMESPACE}.svc.cluster.local:${MYSQL_CONTAINER_PORT}"
kubectl -n "$K8S_NAMESPACE" get pods
kubectl -n "$K8S_NAMESPACE" get svc "$MYSQL_SERVICE_NAME"
kubectl -n "$K8S_NAMESPACE" get pvc "$MYSQL_PVC_NAME"
