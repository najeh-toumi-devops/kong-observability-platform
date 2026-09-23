#!/usr/bin/env bash
set -euo pipefail

systemctl disable --now kong-observability.target 2>/dev/null || true
systemctl disable --now prometheus alertmanager node_exporter blackbox_exporter postgres_exporter 2>/dev/null || true

rm -f /etc/systemd/system/prometheus.service
rm -f /etc/systemd/system/alertmanager.service
rm -f /etc/systemd/system/node_exporter.service
rm -f /etc/systemd/system/blackbox_exporter.service
rm -f /etc/systemd/system/postgres_exporter.service
rm -f /etc/systemd/system/kong-observability.target

systemctl daemon-reload

echo "Systemd units removed. Configuration/data directories were intentionally preserved."
