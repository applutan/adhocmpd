#!/usr/bin/env bash
# AdHocMPD Installer
# https://github.com/applutan/adhocmpd

set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
INSTALL_USER=0

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Installs AdHocMPD and sets up user or system-wide configuration templates.

Options:
  --user         Install to user directory (~/.local/bin) instead of /usr/local/bin
  --prefix DIR   Custom installation directory prefix (default: /usr/local)
  --help         Show this help message and exit
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --user)
            INSTALL_USER=1
            PREFIX="$HOME/.local"
            shift
            ;;
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --help)
            usage
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
done

BIN_DIR="${PREFIX}/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/adhocmpd"

echo "==> Installing AdHocMPD to ${BIN_DIR}..."
mkdir -p "${BIN_DIR}"
install -m 755 adhocmpd "${BIN_DIR}/adhocmpd"

# Symlinks for convenience
ln -sf "${BIN_DIR}/adhocmpd" "${BIN_DIR}/AdHocMPD"
ln -sf "${BIN_DIR}/adhocmpd" "${BIN_DIR}/adhoc_mpd"

echo "==> Checking user configuration..."
mkdir -p "${CONFIG_DIR}"
if [ ! -f "${CONFIG_DIR}/config" ]; then
    echo "    Creating template config at ${CONFIG_DIR}/config..."
    cp adhocmpd.conf.example "${CONFIG_DIR}/config"
    chmod 600 "${CONFIG_DIR}/config"
else
    echo "    Existing config found at ${CONFIG_DIR}/config (preserved)."
fi

echo "==> Verifying dependencies..."
if ! command -v mpc >/dev/null 2>&1; then
    echo "    [NOTE] 'mpc' client is not installed. Please install it with your package manager:"
    echo "           Debian/Ubuntu: sudo apt install mpc"
    echo "           Arch Linux:    sudo pacman -S mpc"
    echo "           Fedora:        sudo dnf install mpc"
    echo "           macOS:         brew install mpc"
else
    echo "    [OK] 'mpc' client detected."
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "    [NOTE] 'jq' is not installed (optional, recommended for -j/--json pipeline mode)."
else
    echo "    [OK] 'jq' detected."
fi

echo ""
echo "AdHocMPD successfully installed!"
echo "Run 'adhocmpd --help' or 'AdHocMPD --help' to get started."
