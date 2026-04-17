#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"

statefulset_exists="false"

# Namespace is the logical boundary for all easy-bank development resources.
kubectl apply -f "$K8S_DIR/namespace.yaml"

# Redis and Sentinel both depend on the password stored in this Secret.
kubectl -n "$K8S_NAMESPACE" get secret "$REDIS_SECRET_NAME" >/dev/null 2>&1 || {
    echo "Secret $REDIS_SECRET_NAME does not exist in namespace $K8S_NAMESPACE." >&2
    echo "Run ./env/dev/02_redis/minikube/01-create-secret.sh first." >&2
    exit 1
}

# If the StatefulSet already exists, a restart is needed for ConfigMap-based settings
# to be re-copied into the running containers.
kubectl -n "$K8S_NAMESPACE" get statefulset "$REDIS_STATEFULSET_NAME" >/dev/null 2>&1 && statefulset_exists="true"

kubectl apply -f "$K8S_DIR/redis-configmap.yaml"
kubectl apply -f "$K8S_DIR/redis-headless-service.yaml"
kubectl apply -f "$K8S_DIR/redis-sentinel-service.yaml"
kubectl apply -f "$K8S_DIR/redis-statefulset.yaml"

if [[ "$statefulset_exists" == "true" ]]; then
    echo "Restarting statefulset $REDIS_STATEFULSET_NAME so updated Redis/Sentinel settings take effect."
    kubectl -n "$K8S_NAMESPACE" rollout restart statefulset/"$REDIS_STATEFULSET_NAME"
fi

kubectl -n "$K8S_NAMESPACE" rollout status statefulset/"$REDIS_STATEFULSET_NAME" --timeout=300s

echo "Redis Sentinel endpoint: ${REDIS_SENTINEL_SERVICE_NAME}.${K8S_NAMESPACE}.svc.cluster.local:${REDIS_SENTINEL_PORT}"
echo "Redis master name: ${REDIS_MASTER_NAME}"
kubectl -n "$K8S_NAMESPACE" get pods -l app="$REDIS_STATEFULSET_NAME"
kubectl -n "$K8S_NAMESPACE" get svc "$REDIS_HEADLESS_SERVICE_NAME"
kubectl -n "$K8S_NAMESPACE" get svc "$REDIS_SENTINEL_SERVICE_NAME"
kubectl -n "$K8S_NAMESPACE" get configmap "$REDIS_CONFIGMAP_NAME"
kubectl -n "$K8S_NAMESPACE" get pvc
