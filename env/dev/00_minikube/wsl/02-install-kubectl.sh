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
sudo apt-get install -y ca-certificates curl

KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"

curl -fsSLo "$TMP_DIR/kubectl" "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"
curl -fsSLo "$TMP_DIR/kubectl.sha256" "https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl.sha256"

(cd "$TMP_DIR" && echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check)

sudo install -o root -g root -m 0755 "$TMP_DIR/kubectl" /usr/local/bin/kubectl

kubectl version --client
