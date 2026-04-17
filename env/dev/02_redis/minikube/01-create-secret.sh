#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"

REDIS_PASSWORD="${REDIS_PASSWORD:-$REDIS_PASSWORD_DEFAULT}"

# Ensure the namespace exists before creating namespaced resources inside it.
kubectl apply -f "$K8S_DIR/namespace.yaml"

# Keep credentials in a Kubernetes Secret instead of hardcoding them into manifests.
# `--dry-run=client -o yaml | kubectl apply -f -` keeps the command repeatable.
kubectl -n "$K8S_NAMESPACE" create secret generic "$REDIS_SECRET_NAME" \
    --from-literal=redis-password="$REDIS_PASSWORD" \
    --dry-run=client \
    -o yaml | kubectl apply -f -

echo "Redis Secret applied to namespace $K8S_NAMESPACE."
