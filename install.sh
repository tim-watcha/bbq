#!/usr/bin/env bash
set -euo pipefail

REPO="tim-watcha/bbq"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="bbq"

echo "Installing bbq (BaBigQuery)..."

# Check dependencies
if ! command -v bq &>/dev/null; then
  echo "error: bq CLI not found. Install Google Cloud SDK first." >&2
  exit 1
fi

if ! command -v curl &>/dev/null; then
  echo "error: curl is required to download bbq." >&2
  exit 1
fi

# Download
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

curl -fsSL "https://raw.githubusercontent.com/${REPO}/main/bbq" -o "$TMPFILE"

# Install
if [ -w "$INSTALL_DIR" ]; then
  install -m 755 "$TMPFILE" "${INSTALL_DIR}/${BINARY_NAME}"
else
  echo "Need sudo to install to ${INSTALL_DIR}"
  sudo install -m 755 "$TMPFILE" "${INSTALL_DIR}/${BINARY_NAME}"
fi

echo "Done! Installed to ${INSTALL_DIR}/${BINARY_NAME}"
echo "Run 'bbq' to get started."
