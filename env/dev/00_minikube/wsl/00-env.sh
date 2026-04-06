#!/usr/bin/env bash

MINIKUBE_ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$MINIKUBE_ENV_DIR/../../../.." && pwd)"

# `profile` is the name of one local minikube cluster instance.
# We pin this project to `easy-bank-dev` so later start/status/delete commands
# always target the same cluster instead of whichever profile happens to be active.
MINIKUBE_PROFILE="${MINIKUBE_PROFILE:-easy-bank-dev}"
MINIKUBE_CPUS="${MINIKUBE_CPUS:-16}"
MINIKUBE_MEMORY="${MINIKUBE_MEMORY:-16384}"
MINIKUBE_DISK_SIZE="${MINIKUBE_DISK_SIZE:-40g}"
K8S_NAMESPACE="${K8S_NAMESPACE:-easy-bank-dev}"
