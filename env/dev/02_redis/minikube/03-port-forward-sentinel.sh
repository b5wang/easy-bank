
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"

kubectl -n "$K8S_NAMESPACE" get svc "$REDIS_SENTINEL_SERVICE_NAME" >/dev/null 2>&1 || {
    echo "Service $REDIS_SENTINEL_SERVICE_NAME does not exist in namespace $K8S_NAMESPACE." >&2
    echo "Run ./env/dev/02_redis/minikube/02-deploy-redis.sh first." >&2
    exit 1
}

# `port-forward` opens a temporary tunnel from localhost to the Sentinel Service.
# Keep this terminal window open while local applications or tools are using it.
# Note: Sentinel returns Kubernetes-internal Pod addresses such as
# `*.svc.cluster.local`, so host-side GUI tools on Windows/WSL often cannot
# resolve them directly. For normal data access from the host, use
# `04-port-forward-master.sh` instead.
echo "Forwarding 127.0.0.1:${REDIS_LOCAL_SENTINEL_PORT} -> ${REDIS_SENTINEL_SERVICE_NAME}:${REDIS_SENTINEL_PORT}"
echo "Use this endpoint mainly for Sentinel inspection and troubleshooting."
echo "For host-side Redis GUI/data access, prefer ./env/dev/02_redis/minikube/04-port-forward-master.sh."
kubectl -n "$K8S_NAMESPACE" port-forward "svc/${REDIS_SENTINEL_SERVICE_NAME}" "${REDIS_LOCAL_SENTINEL_PORT}:${REDIS_SENTINEL_PORT}"
