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

install_cron() {
	local cron_job="*/5 * * * * bash ${MONITOR} once >> /var/log/health-monitor.log 2>&1"

	if crontab -l 2>/dev/null | grep -q "$MONITOR"; then
		echo "Cron job already exists - skipping"
	else
		(crontab -l 2>/dev/null; echo "$cron_job") | crontab -
		echo "Cron job installed: every 5 minutes"
	fi
	echo "Check crontab: crontab -l"
}

install_daemon() {
	local service_file="/etc/systemd/system/health-monitor.service"

	cat > "$service_file" <<EOF
[Unit]
Description=Server Health Monitor
After=network.target

[Service]
Type=Simple
ExecStart=/bin/bash ${MONITOR} daemon
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

	systemctl daemon-reload
	systemctl enable health-monitor > /dev/null 2>&1
	systemctl restart health-monitor

	echo "Systemd service installed and sterted"
	echo "Check status: systemctl status health-monitor"
	echo "Check logs: journalctl -u health-monitor -f"
}
