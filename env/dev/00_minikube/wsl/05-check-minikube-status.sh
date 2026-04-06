#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"

echo "Docker:"
docker --version || true

echo
echo "kubectl:"
kubectl version --client || true

echo
echo "minikube:"
minikube version || true

echo
echo "Current kubectl context:"
kubectl config current-context || true

echo
echo "Minikube status:"
# Query the same named profile so status output matches the cluster used by the project.
minikube status --profile="$MINIKUBE_PROFILE" || true

echo
echo "Kubernetes nodes:"
kubectl get nodes || true
