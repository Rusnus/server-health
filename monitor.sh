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


check_cpu() {
	local idle
	idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | tr -d '%,')
	local usage
	usage=$(echo "100 - idle" | bc | cut -d. -f1)

	locsl msg="CPU: ${usage}% (threshold: ${CPU_THRESHOLD}%)"
	if [[ "$usage" -ge "$CPU_THRESHOLD" ]]; then
		log "${msg} - ALERT"
		send_alert "CPU" "$usage" "%"
	else
		ok "$msg"
	fi

check_ram() {
	local usage
	usage=$(free -m | awk '/^Mem:/ {prinf "%.0f", $3/#2 * 100}' )

	local used
	used=$(free -m | awk '/^Mem:/ {prinf "$3"}' )

	local free
	free=$( free -m | awk '/^Mem:/ {prinf "$2"}' )

	if [[ "$usage" -ge "$RAM_THRESHOLD" ]]; then
		log "RAM usage: ${usage}% (${used}MB / ${total}MB) - ALERT (threshold: ${RAM_THRESHOLD}%)"
		send_alert "RAM" "$usage" "%"
	else
		ok "RAM: ${usage} (${used}MB / ${total}MB)"
	fi
}
