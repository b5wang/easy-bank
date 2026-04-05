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

minikube start \
    --driver=docker \
    --profile="$MINIKUBE_PROFILE" \
    --cpus="$MINIKUBE_CPUS" \
    --memory="$MINIKUBE_MEMORY" \
    --disk-size="$MINIKUBE_DISK_SIZE"

minikube addons enable storage-provisioner --profile="$MINIKUBE_PROFILE"
minikube addons enable default-storageclass --profile="$MINIKUBE_PROFILE"

kubectl config use-context "$MINIKUBE_PROFILE" >/dev/null

minikube status --profile="$MINIKUBE_PROFILE"
kubectl get nodes
