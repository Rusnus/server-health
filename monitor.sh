#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_FILE="${SCRIPT_DIR}/config.conf"
[[ -f "$CONFIG_FILE" ]] || { echo "ERROR: config.conf not found"; exit 1; }
source "$CONFIG_FILE"

ALERT_FILE="${SCRIPT_DIR}/alert.sh"
[[ -f "$ALERT_FILE" ]] || { echo "ERROR: alert.sh not found"; exit 1; }
source "$ALERT_FILE"

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "$(date '+%d.%m.%Y %H:%M:%S') [monitor] $*" | tee -a "$LOG_FILE"; }
ok() { echo -e "$(date '+%d.%m.%Y %H:%M:%S')${GREEN}[OK]${NC} $*" | tee -a "$LOG_FILE"; }


