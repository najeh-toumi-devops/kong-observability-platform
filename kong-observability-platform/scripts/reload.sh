#!/usr/bin/env bash
set -euo pipefail

promtool check config /etc/prometheus/prometheus.yml
promtool check rules /etc/prometheus/rules/*.yml

systemctl reload prometheus 2>/dev/null || systemctl restart prometheus

echo "Prometheus configuration reloaded."
