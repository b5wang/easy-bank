#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-env.sh"

if ! grep -qiE "(microsoft|wsl)" /proc/version; then
    echo "This script must be run inside WSL." >&2
    exit 1
fi

if [[ ! -f /etc/os-release ]]; then
    echo "/etc/os-release is missing." >&2
    exit 1
fi

source /etc/os-release

if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "22.04" ]]; then
    echo "This development setup expects Ubuntu 22.04. Current distro: ${PRETTY_NAME:-unknown}" >&2
    exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
    echo "docker command is not available inside WSL." >&2
    echo "Enable Docker Desktop WSL integration for Ubuntu-22.04 first." >&2
    exit 1
fi

docker info >/dev/null 2>&1 || {
    echo "docker info failed inside WSL." >&2
    echo "Start Docker Desktop on Windows and enable the WSL 2 backend and Ubuntu-22.04 integration." >&2
    exit 1
}

echo "WSL verification passed."
echo "Distro: ${PRETTY_NAME}"
docker --version
