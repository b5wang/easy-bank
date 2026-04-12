#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"

deployment_exists="false"

# Namespace is the logical boundary inside the cluster for this project environment.
kubectl apply -f "$K8S_DIR/namespace.yaml"

# The Deployment reads its root password from this Secret, so fail fast if it is missing.
kubectl -n "$K8S_NAMESPACE" get secret "$MYSQL_SECRET_NAME" >/dev/null 2>&1 || {
    echo "Secret $MYSQL_SECRET_NAME does not exist in namespace $K8S_NAMESPACE." >&2
    echo "Run ./env/dev/01_mysql/minikube/01-create-secret.sh first." >&2
    exit 1
}

# If the Deployment already exists, later config-file changes need a Pod restart to take effect.
kubectl -n "$K8S_NAMESPACE" get deployment "$MYSQL_DEPLOYMENT_NAME" >/dev/null 2>&1 && deployment_exists="true"

# ConfigMap provides the mounted .cnf file; PVC keeps data on persistent storage;
# Deployment creates the Pod; Service gives a stable in-cluster address.
kubectl apply -f "$K8S_DIR/mysql-configmap.yaml"
kubectl apply -f "$K8S_DIR/mysql-pvc.yaml"
kubectl apply -f "$K8S_DIR/mysql-deployment.yaml"
kubectl apply -f "$K8S_DIR/mysql-service.yaml"

# MySQL reads these settings only at process start, so restart the Deployment when it already existed.
if [[ "$deployment_exists" == "true" ]]; then
    echo "Restarting deployment $MYSQL_DEPLOYMENT_NAME so ConfigMap-based MySQL settings take effect."
    kubectl -n "$K8S_NAMESPACE" rollout restart deployment/"$MYSQL_DEPLOYMENT_NAME"
fi

# Wait until Kubernetes reports the MySQL Pod is ready before printing follow-up connection info.
kubectl -n "$K8S_NAMESPACE" rollout status deployment/"$MYSQL_DEPLOYMENT_NAME" --timeout=300s

echo "Cluster MySQL endpoint: ${MYSQL_SERVICE_NAME}.${K8S_NAMESPACE}.svc.cluster.local:${MYSQL_CONTAINER_PORT}"
kubectl -n "$K8S_NAMESPACE" get pods
kubectl -n "$K8S_NAMESPACE" get svc "$MYSQL_SERVICE_NAME"
kubectl -n "$K8S_NAMESPACE" get configmap "$MYSQL_CONFIGMAP_NAME"
kubectl -n "$K8S_NAMESPACE" get pvc "$MYSQL_PVC_NAME"
