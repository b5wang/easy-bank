#!/usr/bin/env bash

MYSQL_ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MYSQL_ENV_DIR/../../00_minikube/wsl/00-env.sh"

# Deployment/Service/Secret/PVC names are kept explicit so kubectl commands,
# YAML manifests, and troubleshooting output all point to the same resource names.
MYSQL_DEPLOYMENT_NAME="${MYSQL_DEPLOYMENT_NAME:-eb-mysql}"
MYSQL_SERVICE_NAME="${MYSQL_SERVICE_NAME:-eb-mysql}"
MYSQL_SECRET_NAME="${MYSQL_SECRET_NAME:-eb-mysql-secret}"
MYSQL_CONFIGMAP_NAME="${MYSQL_CONFIGMAP_NAME:-eb-mysql-config}"
MYSQL_PVC_NAME="${MYSQL_PVC_NAME:-eb-mysql-data}"
# Local port is for the developer machine; container port is the MySQL port inside Kubernetes.
MYSQL_LOCAL_PORT="${MYSQL_LOCAL_PORT:-13306}"
MYSQL_CONTAINER_PORT="${MYSQL_CONTAINER_PORT:-3306}"

# Default credentials are only for the local development cluster.
MYSQL_ROOT_PASSWORD_DEFAULT="${MYSQL_ROOT_PASSWORD_DEFAULT:-eb_root_dev_123456}"
MYSQL_APP_USER_DEFAULT="${MYSQL_APP_USER_DEFAULT:-eb_app}"
MYSQL_APP_PASSWORD_DEFAULT="${MYSQL_APP_PASSWORD_DEFAULT:-eb_app_dev_123456}"

K8S_DIR="${K8S_DIR:-$MYSQL_ENV_DIR/k8s}"
