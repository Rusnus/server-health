#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONITOR="${SCRIPT_DIR}/monitor.sh"

[[ "$EUID" -eq 0 ]] || { echo "ERROR: Run as root: sudo bash install.sh"; exit 1; }
[[ -f "$MONITOR" ]] || { echo "ERROR: monitor.sh not found"; exit 1; }

chmod +x "$MONITOR"

usage() {
	echo "Usage: sudo bash install.sh [--cron | --daemon | --remove]"
	echo ""
	echo " --cron	Install to run via cron every 5 minutes"
	echo " --daemon	Install as a systemd service(runs continuously)"
	echo " --remove	Remove the cron job and the systemd service"
}
