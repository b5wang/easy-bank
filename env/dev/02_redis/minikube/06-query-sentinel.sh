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

usage() {
    cat <<'EOF'
Usage:
  ./env/dev/02_redis/minikube/06-query-sentinel.sh [all|masters|master-addr|replicas|sentinels|quorum] [master-name]

Examples:
  ./env/dev/02_redis/minikube/06-query-sentinel.sh
  ./env/dev/02_redis/minikube/06-query-sentinel.sh master-addr
  ./env/dev/02_redis/minikube/06-query-sentinel.sh replicas
  ./env/dev/02_redis/minikube/06-query-sentinel.sh sentinels ebmaster
EOF
}

require_cmd kubectl

query_type="${1:-all}"
master_name="${2:-$REDIS_MASTER_NAME}"

case "$query_type" in
    -h|--help|help)
        usage
        exit 0
        ;;
esac

kubectl -n "$K8S_NAMESPACE" get statefulset "$REDIS_STATEFULSET_NAME" >/dev/null 2>&1 || {
    echo "StatefulSet $REDIS_STATEFULSET_NAME does not exist in namespace $K8S_NAMESPACE." >&2
    echo "Run ./env/dev/02_redis/minikube/02-deploy-redis.sh first." >&2
    exit 1
}

sentinel_pod="$(kubectl -n "$K8S_NAMESPACE" get pods -l app="$REDIS_STATEFULSET_NAME" -o jsonpath='{.items[0].metadata.name}')"

if [[ -z "$sentinel_pod" ]]; then
    echo "No Redis pods found in namespace $K8S_NAMESPACE." >&2
    exit 1
fi

run_sentinel() {
    kubectl -n "$K8S_NAMESPACE" exec "$sentinel_pod" -c sentinel -- \
        redis-cli -p "$REDIS_SENTINEL_PORT" --raw SENTINEL "$@"
}

echo "Using Sentinel pod: $sentinel_pod"
echo "Namespace: $K8S_NAMESPACE"
echo "Master name: $master_name"

case "$query_type" in
    all)
        echo
        echo "== SENTINEL masters =="
        run_sentinel masters

        echo
        echo "== SENTINEL get-master-addr-by-name $master_name =="
        run_sentinel get-master-addr-by-name "$master_name"

        echo
        echo "== SENTINEL replicas $master_name =="
        run_sentinel replicas "$master_name"

        echo
        echo "== SENTINEL sentinels $master_name =="
        run_sentinel sentinels "$master_name"

        echo
        echo "== SENTINEL ckquorum $master_name =="
        run_sentinel ckquorum "$master_name"
        ;;
    masters)
        echo
        echo "== SENTINEL masters =="
        run_sentinel masters
        ;;
    master-addr)
        echo
        echo "== SENTINEL get-master-addr-by-name $master_name =="
        run_sentinel get-master-addr-by-name "$master_name"
        ;;
    replicas)
        echo
        echo "== SENTINEL replicas $master_name =="
        run_sentinel replicas "$master_name"
        ;;
    sentinels)
        echo
        echo "== SENTINEL sentinels $master_name =="
        run_sentinel sentinels "$master_name"
        ;;
    quorum)
        echo
        echo "== SENTINEL ckquorum $master_name =="
        run_sentinel ckquorum "$master_name"
        ;;
    *)
        echo "Unknown query type: $query_type" >&2
        echo >&2
        usage >&2
        exit 1
        ;;
esac
