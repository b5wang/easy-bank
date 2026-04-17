#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"

require_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Missing required command: $cmd" >&2
        exit 1
    fi
}

require_cmd kubectl
require_cmd awk

kubectl -n "$K8S_NAMESPACE" get statefulset "$REDIS_STATEFULSET_NAME" >/dev/null 2>&1 || {
    echo "StatefulSet $REDIS_STATEFULSET_NAME does not exist in namespace $K8S_NAMESPACE." >&2
    echo "Run ./env/dev/02_redis/minikube/02-deploy-redis.sh first." >&2
    exit 1
}

# Query one Sentinel instance to discover the current master, then forward traffic
# directly to that Redis Pod for clients that do not understand Sentinel.
sentinel_pod="$(kubectl -n "$K8S_NAMESPACE" get pods -l app="$REDIS_STATEFULSET_NAME" -o jsonpath='{.items[0].metadata.name}')"

if [[ -z "$sentinel_pod" ]]; then
    echo "No Redis pods found in namespace $K8S_NAMESPACE." >&2
    exit 1
fi

mapfile -t master_info < <(
    kubectl -n "$K8S_NAMESPACE" exec "$sentinel_pod" -c sentinel -- \
        redis-cli -p "$REDIS_SENTINEL_PORT" --raw SENTINEL get-master-addr-by-name "$REDIS_MASTER_NAME"
)

if [[ ${#master_info[@]} -lt 2 ]]; then
    echo "Unable to query the current master from Sentinel." >&2
    exit 1
fi

master_host="${master_info[0]}"
master_port="${master_info[1]}"
master_pod="${master_host%%.*}"

# If Sentinel returns a Pod IP instead of a hostname, map the IP back to a Pod name.
if [[ ! "$master_pod" =~ ^${REDIS_STATEFULSET_NAME}-[0-9]+$ ]]; then
    master_pod="$(
        kubectl -n "$K8S_NAMESPACE" get pods -l app="$REDIS_STATEFULSET_NAME" \
            -o custom-columns=NAME:.metadata.name,IP:.status.podIP --no-headers |
            awk -v host="$master_host" '$2 == host {print $1; exit}'
    )"
fi

if [[ -z "$master_pod" ]]; then
    echo "Unable to map Sentinel master host '$master_host' to a Redis Pod." >&2
    exit 1
fi

echo "Current Redis master: ${master_host}:${master_port}"
echo "Forwarding 127.0.0.1:${REDIS_LOCAL_MASTER_PORT} -> pod/${master_pod}:${master_port}"
kubectl -n "$K8S_NAMESPACE" port-forward "pod/${master_pod}" "${REDIS_LOCAL_MASTER_PORT}:${master_port}"
