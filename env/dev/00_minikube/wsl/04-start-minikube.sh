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

require_cmd docker
require_cmd minikube
require_cmd kubectl

docker info >/dev/null
minikube config set driver docker

# `--profile` chooses which named minikube cluster to create or start.
# Without it, commands may hit a different local cluster and mix environments.
minikube start \
    --driver=docker \
    --profile="$MINIKUBE_PROFILE" \
    --cpus="$MINIKUBE_CPUS" \
    --memory="$MINIKUBE_MEMORY" \
    --disk-size="$MINIKUBE_DISK_SIZE"

# These addon changes are also scoped to the same named profile.
minikube addons enable storage-provisioner --profile="$MINIKUBE_PROFILE"
minikube addons enable default-storageclass --profile="$MINIKUBE_PROFILE"
# `dashboard` provides the basic Kubernetes web UI.
# `metrics-server` lets the dashboard show CPU/memory usage instead of only object lists.
minikube addons enable dashboard --profile="$MINIKUBE_PROFILE"
minikube addons enable metrics-server --profile="$MINIKUBE_PROFILE"

# The kubectl context created by minikube uses the profile name as its context name.
kubectl config use-context "$MINIKUBE_PROFILE" >/dev/null

minikube status --profile="$MINIKUBE_PROFILE"
kubectl get nodes

echo
echo "Dashboard hint:"
echo "Run: minikube dashboard --profile=${MINIKUBE_PROFILE} --url"
echo "Keep that terminal open while using the dashboard URL."
