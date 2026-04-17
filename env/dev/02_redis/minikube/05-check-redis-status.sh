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

echo "StatefulSet:"
kubectl -n "$K8S_NAMESPACE" get statefulset "$REDIS_STATEFULSET_NAME" || true

echo
echo "Services:"
kubectl -n "$K8S_NAMESPACE" get svc "$REDIS_HEADLESS_SERVICE_NAME" || true
kubectl -n "$K8S_NAMESPACE" get svc "$REDIS_SENTINEL_SERVICE_NAME" || true

echo
echo "Pods:"
kubectl -n "$K8S_NAMESPACE" get pods -l app="$REDIS_STATEFULSET_NAME" -o wide || true

echo
echo "PVCs:"
kubectl -n "$K8S_NAMESPACE" get pvc || true

echo
echo "Redis roles:"
mapfile -t redis_pods < <(kubectl -n "$K8S_NAMESPACE" get pods -l app="$REDIS_STATEFULSET_NAME" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
for pod in "${redis_pods[@]}"; do
    [[ -z "$pod" ]] && continue
    role="$(
        kubectl -n "$K8S_NAMESPACE" exec "$pod" -c redis -- sh -lc \
            'redis-cli -a "$REDIS_PASSWORD" --no-auth-warning INFO replication | awk -F: "/^role:/{print \$2}"' \
            2>/dev/null | tr -d '\r'
    )"
    master_host="$(
        kubectl -n "$K8S_NAMESPACE" exec "$pod" -c redis -- sh -lc \
            'redis-cli -a "$REDIS_PASSWORD" --no-auth-warning INFO replication | awk -F: "/^master_host:/{print \$2}"' \
            2>/dev/null | tr -d '\r'
    )"
    if [[ "$role" == "slave" || "$role" == "replica" ]]; then
        echo "- $pod: $role of $master_host"
    else
        echo "- $pod: $role"
    fi
done

if [[ ${#redis_pods[@]} -gt 0 ]]; then
    first_pod="${redis_pods[0]}"
    echo
    echo "Sentinel current master:"
    kubectl -n "$K8S_NAMESPACE" exec "$first_pod" -c sentinel -- \
        redis-cli -p "$REDIS_SENTINEL_PORT" --raw SENTINEL get-master-addr-by-name "$REDIS_MASTER_NAME" || true

    echo
    echo "Sentinel master detail:"
    kubectl -n "$K8S_NAMESPACE" exec "$first_pod" -c sentinel -- \
        redis-cli -p "$REDIS_SENTINEL_PORT" --raw SENTINEL master "$REDIS_MASTER_NAME" || true
fi
