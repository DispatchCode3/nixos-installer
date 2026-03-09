#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$REPO_ROOT/templates/machine-config.nix"
OUTPUT_DIR="$REPO_ROOT/generated"
OUTPUT_FILE="$OUTPUT_DIR/flake.nix"

mkdir -p "$OUTPUT_DIR"

prompt() {
  local label="$1"
  local default="${2:-}"
  local value

  if [[ -n "$default" ]]; then
    read -r -p "$label [$default]: " value
    value="${value:-$default}"
  else
    read -r -p "$label: " value
  fi

  printf '%s' "$value"
}

echo "NixOS installer config generator"
echo

SYSTEM="$(prompt "System architecture" "x86_64-linux")"
CONFIG_NAME="$(prompt "Config name" "generated")"
HOSTNAME="$(prompt "Hostname")"
USERNAME="$(prompt "Username")"
TIMEZONE="$(prompt "Timezone" "America/Chicago")"
LOCALE="$(prompt "Locale" "en_US.UTF-8")"
STATE_VERSION="$(prompt "State version" "24.11")"

echo
echo "Host types: desktop, laptop, vm, portable-usb, server"
HOST="$(prompt "Host type")"

echo
echo "Roles available: minimal, workstation, dev, gaming, vm-host"
ROLE_INPUT="$(prompt "Roles (comma-separated)" "minimal")"

IFS=',' read -r -a ROLE_ARRAY <<< "$ROLE_INPUT"

ROLES_RENDERED=""
for role in "${ROLE_ARRAY[@]}"; do
  role="$(echo "$role" | xargs)"
  [[ -z "$role" ]] && continue
  ROLES_RENDERED="${ROLES_RENDERED}          \"${role}\"\n"
done

if [[ -z "$ROLES_RENDERED" ]]; then
  ROLES_RENDERED='          "minimal"\n'
fi

rendered="$(cat "$TEMPLATE")"
rendered="${rendered//'{{SYSTEM}}'/$SYSTEM}"
rendered="${rendered//'{{CONFIG_NAME}}'/$CONFIG_NAME}"
rendered="${rendered//'{{HOST}}'/$HOST}"
rendered="${rendered//'{{HOSTNAME}}'/$HOSTNAME}"
rendered="${rendered//'{{USERNAME}}'/$USERNAME}"
rendered="${rendered//'{{TIMEZONE}}'/$TIMEZONE}"
rendered="${rendered//'{{LOCALE}}'/$LOCALE}"
rendered="${rendered//'{{STATE_VERSION}}'/$STATE_VERSION}"

roles_block="$(printf "%b" "$ROLES_RENDERED")"
rendered="${rendered//'{{ROLES}}'/$roles_block}"

printf '%s\n' "$rendered" > "$OUTPUT_FILE"

echo
echo "Generated: $OUTPUT_FILE"
echo
echo "Next step:"
echo "  nixos-install --flake $OUTPUT_DIR#$CONFIG_NAME"
