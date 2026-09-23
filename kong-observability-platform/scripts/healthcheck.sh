#!/usr/bin/env bash
set -u

services=(
  kong
  prometheus
  grafana-server
  node_exporter
  blackbox_exporter
  postgres_exporter
  alertmanager
)

echo "========================================"
echo " Kong Observability Health Check"
echo "========================================"

for service in "${services[@]}"; do
  if systemctl is-active --quiet "$service"; then
    echo "[OK]   $service"
  else
    echo "[FAIL] $service"
  fi
done

check_endpoint() {
  local name="$1"
  local url="$2"

  if curl -fsS "$url" >/dev/null 2>&1; then
    echo "[OK]   $name"
  else
    echo "[FAIL] $name"
  fi
}

check_endpoint "Kong metrics" "http://127.0.0.1:8007/metrics"
check_endpoint "Prometheus" "http://127.0.0.1:9090/-/ready"
check_endpoint "Alertmanager" "http://127.0.0.1:9093/-/ready"
check_endpoint "Node Exporter" "http://127.0.0.1:9100/metrics"
check_endpoint "Blackbox Exporter" "http://127.0.0.1:9115/metrics"
check_endpoint "PostgreSQL Exporter" "http://127.0.0.1:9187/metrics"

echo "========================================"
