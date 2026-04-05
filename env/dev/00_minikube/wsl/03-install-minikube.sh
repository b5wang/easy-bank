#!/usr/bin/env bash
set -euo pipefail

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64) echo "amd64" ;;
        aarch64|arm64) echo "arm64" ;;
        *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
    esac
}

ARCH="$(detect_arch)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

sudo apt-get update
sudo apt-get install -y ca-certificates curl conntrack

curl -fsSLo "$TMP_DIR/minikube" "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-${ARCH}"
curl -fsSLo "$TMP_DIR/minikube.sha256" "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-${ARCH}.sha256"

(cd "$TMP_DIR" && echo "$(cat minikube.sha256)  minikube" | sha256sum --check)

sudo install -o root -g root -m 0755 "$TMP_DIR/minikube" /usr/local/bin/minikube

minikube version
minikube config set driver docker
