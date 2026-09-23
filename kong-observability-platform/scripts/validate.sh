#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Prometheus configuration"
promtool check config /etc/prometheus/prometheus.yml

echo "[2/4] Prometheus rules"
promtool check rules /etc/prometheus/rules/*.yml

echo "[3/4] Blackbox configuration"
blackbox_exporter --config.file=/etc/blackbox_exporter/blackbox.yml --config.check

echo "[4/4] Grafana JSON"
python3 -m json.tool config/grafana/dashboards/kong-overview.json >/dev/null

echo "Validation successful."
