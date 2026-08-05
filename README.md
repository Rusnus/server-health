# server-health-monitor

> 🇷🇺 [Русская версия](README.ru.md)

A Bash script for monitoring an Ubuntu server. Checks CPU, RAM, disk, and services — sends alerts via Telegram and email when thresholds are exceeded.

Two launch modes: **cron** (every 5 minutes) or **systemd daemon** (runs continuously).

---

## What it monitors

| Metric | Default threshold | Alert condition |
|---|---|---|
| CPU | 80% | Usage exceeds threshold |
| RAM | 85% | Usage exceeds threshold |
| Disk | 90% | Checked per partition |
| Services | — | Service is stopped |

---
