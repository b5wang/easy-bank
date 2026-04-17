#!/usr/bin/env bash

REDIS_ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REDIS_ENV_DIR/../../00_minikube/wsl/00-env.sh"

# These names are kept explicit so scripts, manifests, and troubleshooting output
# always refer to the same Redis resources.
REDIS_STATEFULSET_NAME="${REDIS_STATEFULSET_NAME:-eb-redis}"
REDIS_HEADLESS_SERVICE_NAME="${REDIS_HEADLESS_SERVICE_NAME:-eb-redis-headless}"
REDIS_SENTINEL_SERVICE_NAME="${REDIS_SENTINEL_SERVICE_NAME:-eb-redis-sentinel}"
REDIS_CONFIGMAP_NAME="${REDIS_CONFIGMAP_NAME:-eb-redis-config}"
REDIS_SECRET_NAME="${REDIS_SECRET_NAME:-eb-redis-secret}"

# Service-discovery and local-access ports.
REDIS_PORT="${REDIS_PORT:-6379}"
REDIS_SENTINEL_PORT="${REDIS_SENTINEL_PORT:-26379}"
REDIS_LOCAL_SENTINEL_PORT="${REDIS_LOCAL_SENTINEL_PORT:-26379}"
REDIS_LOCAL_MASTER_PORT="${REDIS_LOCAL_MASTER_PORT:-16379}"

# Development-environment topology and image baseline.
REDIS_REPLICAS="${REDIS_REPLICAS:-3}"
REDIS_IMAGE="${REDIS_IMAGE:-redis:8.6.0}"
REDIS_MASTER_NAME="${REDIS_MASTER_NAME:-ebmaster}"
REDIS_MASTER_POD_FQDN="${REDIS_MASTER_POD_FQDN:-eb-redis-0.eb-redis-headless.${K8S_NAMESPACE}.svc.cluster.local}"

# Password is shared by the master and replicas in this local development setup.
REDIS_PASSWORD_DEFAULT="${REDIS_PASSWORD_DEFAULT:-eb_redis_dev_123456}"

# PVC and memory settings are intentionally modest for local development.
REDIS_PVC_SIZE="${REDIS_PVC_SIZE:-5Gi}"
REDIS_MAXMEMORY="${REDIS_MAXMEMORY:-256mb}"

# Sentinel settings model a small but realistic majority-based failover.
REDIS_SENTINEL_QUORUM="${REDIS_SENTINEL_QUORUM:-2}"
REDIS_SENTINEL_DOWN_AFTER_MS="${REDIS_SENTINEL_DOWN_AFTER_MS:-10000}"
REDIS_SENTINEL_FAILOVER_TIMEOUT_MS="${REDIS_SENTINEL_FAILOVER_TIMEOUT_MS:-60000}"
REDIS_SENTINEL_PARALLEL_SYNCS="${REDIS_SENTINEL_PARALLEL_SYNCS:-1}"

K8S_DIR="${K8S_DIR:-$REDIS_ENV_DIR/k8s}"
