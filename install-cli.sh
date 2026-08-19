#!/usr/bin/env bash
# Install the curlix CLI binary from a GitHub Release (no Homebrew required).
#
# Usage:
#   curl -fsSL https://releases.curlix.io/release/install-cli.sh | bash
#   curl -fsSL ... | bash -s -- --version 1.2.3
#   curl -fsSL ... | bash -s -- --install-dir ~/.local/bin
#
# releases.curlix.io/release/install-cli.sh is a Cloudflare Worker redirect
# (infrastructure/cloudflare-workers/releases-redirect/) in front of a *mirrored copy* of this
# file on curlix-io/homebrew-cli, not this file directly — curlix-io/curlix (this repo) is private, so
# raw.githubusercontent.com can't serve from it publicly. The release-cli.yml "tap" job copies
# this file into the curlix-io/homebrew-cli repo on every release; edit it here, it ships from there.
#
# Environment:
#   CURLIX_CLI_VERSION   — release tag suffix (default: latest cli-v* release)
#   CURLIX_INSTALL_DIR   — destination directory (default: /usr/local/bin or ~/.local/bin)
set -euo pipefail

REPO="${CURLIX_CLI_REPO:-curlix-io/homebrew-cli}"
INSTALL_DIR="${CURLIX_INSTALL_DIR:-}"
VERSION="${CURLIX_CLI_VERSION:-}"

usage() {
  cat <<'EOF'
install-cli.sh — download and install the curlix CLI binary

Options:
  --version VER       Install cli-vVER (default: latest GitHub release)
  --install-dir DIR   Install to DIR (default: /usr/local/bin or ~/.local/bin)
  -h, --help            Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      VERSION="${2:-}"
      shift 2
      ;;
    --install-dir)
      INSTALL_DIR="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$(uname -s)" in
  Darwin) OS="darwin" ;;
  Linux)  OS="linux" ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

case "$(uname -m)" in
  arm64|aarch64) ARCH="arm64" ;;
  x86_64|amd64)  ARCH="x86_64" ;;
  *) echo "Unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac

if [[ -z "$INSTALL_DIR" ]]; then
  if [[ -w /usr/local/bin ]]; then
    INSTALL_DIR="/usr/local/bin"
  else
    INSTALL_DIR="${HOME}/.local/bin"
  fi
fi

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Required command not found: $1" >&2
    exit 1
  }
}

need_cmd curl
need_cmd tar
need_cmd shasum

if [[ -z "$VERSION" ]]; then
  need_cmd python3
  VERSION="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | python3 -c "import json,sys; t=json.load(sys.stdin).get('tag_name',''); print(t.replace('cli-v','') if t.startswith('cli-v') else t)")"
  if [[ -z "$VERSION" ]]; then
    echo "Could not resolve latest CLI release from GitHub." >&2
    exit 1
  fi
fi

TAG="cli-v${VERSION}"
ASSET="curlix-${VERSION}-${OS}-${ARCH}.tar.gz"
BASE_URL="https://github.com/${REPO}/releases/download/${TAG}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> Downloading ${ASSET} (${TAG})"
curl -fsSL "${BASE_URL}/${ASSET}" -o "${TMP}/${ASSET}"
curl -fsSL "${BASE_URL}/${ASSET}.sha256" -o "${TMP}/${ASSET}.sha256"

echo "==> Verifying checksum"
( cd "$TMP" && shasum -a 256 -c "${ASSET}.sha256" )

echo "==> Extracting"
tar -C "$TMP" -xzf "${TMP}/${ASSET}"

mkdir -p "$INSTALL_DIR"
install -m 0755 "${TMP}/curlix/curlix" "${INSTALL_DIR}/curlix"

echo "==> Installed curlix ${VERSION} to ${INSTALL_DIR}/curlix"
if ! command -v curlix >/dev/null 2>&1; then
  echo "Add ${INSTALL_DIR} to your PATH if needed, then run: curlix login"
fi
