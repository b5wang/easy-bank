#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"

MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-$MYSQL_ROOT_PASSWORD_DEFAULT}"
MYSQL_APP_USER="${MYSQL_APP_USER:-$MYSQL_APP_USER_DEFAULT}"
MYSQL_APP_PASSWORD="${MYSQL_APP_PASSWORD:-$MYSQL_APP_PASSWORD_DEFAULT}"

kubectl apply -f "$K8S_DIR/namespace.yaml"

kubectl -n "$K8S_NAMESPACE" create secret generic "$MYSQL_SECRET_NAME" \
    --from-literal=mysql-root-password="$MYSQL_ROOT_PASSWORD" \
    --from-literal=mysql-app-user="$MYSQL_APP_USER" \
    --from-literal=mysql-app-password="$MYSQL_APP_PASSWORD" \
    --dry-run=client \
    -o yaml | kubectl apply -f -

echo "MySQL Secret applied to namespace $K8S_NAMESPACE."
echo "Application user: $MYSQL_APP_USER"
