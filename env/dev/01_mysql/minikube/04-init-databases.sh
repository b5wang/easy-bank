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
require_cmd base64

# Each service owns one logical database. The init script creates them in the same MySQL instance.
SERVICE_DATABASE_PAIRS=(
    "eb-service-auth:eb_auth"
    "eb-service-account:eb_account"
    "eb-service-transfer:eb_transfer"
    "eb-service-channel:eb_channel"
    "eb-service-risk:eb_risk"
    "eb-service-notification:eb_notification"
    "eb-service-audit:eb_audit"
    "eb-service-ops:eb_ops"
)

decode_secret_value() {
    local key="$1"
    # Kubernetes Secrets store values as base64-encoded strings, so decode before use.
    kubectl -n "$K8S_NAMESPACE" get secret "$MYSQL_SECRET_NAME" -o "jsonpath={.data.${key}}" | base64 --decode
}

mysql_root_exec() {
    # Execute mysql inside the Pod so initialization does not depend on a local MySQL client.
    kubectl -n "$K8S_NAMESPACE" exec -i "$MYSQL_POD" -- sh -lc 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"'
}

mysql_root_exec_db() {
    local database_name="$1"
    kubectl -n "$K8S_NAMESPACE" exec -i "$MYSQL_POD" -- sh -lc "exec mysql -uroot -p\"\$MYSQL_ROOT_PASSWORD\" \"${database_name}\""
}

mysql_query_value() {
    local sql="$1"
    kubectl -n "$K8S_NAMESPACE" exec "$MYSQL_POD" -- sh -lc "exec mysql -N -B -uroot -p\"\$MYSQL_ROOT_PASSWORD\" -e \"${sql}\""
}

kubectl -n "$K8S_NAMESPACE" get secret "$MYSQL_SECRET_NAME" >/dev/null 2>&1 || {
    echo "Secret $MYSQL_SECRET_NAME does not exist in namespace $K8S_NAMESPACE." >&2
    echo "Run ./env/dev/01_mysql/minikube/01-create-secret.sh first." >&2
    exit 1
}

MYSQL_POD="$(kubectl -n "$K8S_NAMESPACE" get pods -l app="$MYSQL_DEPLOYMENT_NAME" -o jsonpath='{.items[0].metadata.name}')"

if [[ -z "$MYSQL_POD" ]]; then
    echo "MySQL pod not found in namespace $K8S_NAMESPACE." >&2
    echo "Run ./env/dev/01_mysql/minikube/02-deploy-mysql.sh first." >&2
    exit 1
fi

kubectl -n "$K8S_NAMESPACE" wait --for=condition=Ready "pod/${MYSQL_POD}" --timeout=180s

MYSQL_APP_USER="$(decode_secret_value mysql-app-user)"
MYSQL_APP_PASSWORD="$(decode_secret_value mysql-app-password)"

for pair in "${SERVICE_DATABASE_PAIRS[@]}"; do
    service_dir="${pair%%:*}"
    database_name="${pair##*:}"
    create_db_script="${REPO_ROOT}/${service_dir}/db_scripts/create_database.sql"

    # Create the database first so the later schema script has a target schema to connect to.
    echo "Creating database ${database_name} from ${create_db_script}"
    mysql_root_exec < "$create_db_script"
done

{
    printf "CREATE USER IF NOT EXISTS '%s'@'%%' IDENTIFIED BY '%s';\n" "$MYSQL_APP_USER" "$MYSQL_APP_PASSWORD"
    printf "ALTER USER '%s'@'%%' IDENTIFIED BY '%s';\n" "$MYSQL_APP_USER" "$MYSQL_APP_PASSWORD"
    for pair in "${SERVICE_DATABASE_PAIRS[@]}"; do
        database_name="${pair##*:}"
        printf "GRANT ALL PRIVILEGES ON %s.* TO '%s'@'%%';\n" "$database_name" "$MYSQL_APP_USER"
    done
    printf "FLUSH PRIVILEGES;\n"
} | mysql_root_exec

for pair in "${SERVICE_DATABASE_PAIRS[@]}"; do
    service_dir="${pair%%:*}"
    database_name="${pair##*:}"
    init_script="${REPO_ROOT}/${service_dir}/db_scripts/V1__init.sql"
    table_count="$(mysql_query_value "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '${database_name}'")"

    # Skip `V1__init.sql` if tables already exist so the script can be re-run safely.
    if [[ "$table_count" != "0" ]]; then
        echo "Database ${database_name} already contains tables. Skipping ${init_script}."
        continue
    fi

    echo "Initializing schema ${database_name} from ${init_script}"
    mysql_root_exec_db "$database_name" < "$init_script"
done

echo "Database initialization completed."
echo "Application account: ${MYSQL_APP_USER}"
echo "Local endpoint: 127.0.0.1:${MYSQL_LOCAL_PORT}"
echo "Cluster endpoint: ${MYSQL_SERVICE_NAME}.${K8S_NAMESPACE}.svc.cluster.local:${MYSQL_CONTAINER_PORT}"
