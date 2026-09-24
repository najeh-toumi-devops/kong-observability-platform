
#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script as root."
  exit 1
fi

PROMETHEUS_VERSION="${PROMETHEUS_VERSION:-3.13.3}"
NODE_EXPORTER_VERSION="${NODE_EXPORTER_VERSION:-1.12.1}"
BLACKBOX_VERSION="${BLACKBOX_VERSION:-0.28.0}"
POSTGRES_EXPORTER_VERSION="${POSTGRES_EXPORTER_VERSION:-0.20.1}"
ALERTMANAGER_VERSION="${ALERTMANAGER_VERSION:-0.34.1}"
ARCH="linux-amd64"
TMP="/tmp/kong-observability"

if [[ -f config/versions.env ]]; then
  # shellcheck disable=SC1091
  source config/versions.env
fi

mkdir -p "$TMP"

apt-get update
apt-get install -y curl wget tar gzip ca-certificates gnupg lsb-release jq

create_user() {
  local user="$1"
  if ! id "$user" >/dev/null 2>&1; then
    useradd --no-create-home --shell /usr/sbin/nologin "$user"
  fi
}

create_user prometheus
create_user node_exporter
create_user blackbox_exporter
create_user postgres_exporter
create_user alertmanager

install_tar_binary() {
  local url="$1"
  local archive="$2"
  local binary="$3"
  local user="$4"
  local target="/usr/local/bin/$binary"

  cd "$TMP"
  wget -q -O "$archive" "$url"
  tar -xzf "$archive"

  local dir="${archive%.tar.gz}"
  install -o "$user" -g "$user" -m 0755 "$dir/$binary" "$target"
}

install_tar_binary \
  "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.${ARCH}.tar.gz" \
  "prometheus-${PROMETHEUS_VERSION}.${ARCH}.tar.gz" \
  "prometheus" prometheus

install_tar_binary \
  "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.${ARCH}.tar.gz" \
  "node_exporter-${NODE_EXPORTER_VERSION}.${ARCH}.tar.gz" \
  "node_exporter" node_exporter

install_tar_binary \
  "https://github.com/prometheus/blackbox_exporter/releases/download/v${BLACKBOX_VERSION}/blackbox_exporter-${BLACKBOX_VERSION}.${ARCH}.tar.gz" \
  "blackbox_exporter-${BLACKBOX_VERSION}.${ARCH}.tar.gz" \
  "blackbox_exporter" blackbox_exporter

install_tar_binary \
  "https://github.com/prometheus-community/postgres_exporter/releases/download/v${POSTGRES_EXPORTER_VERSION}/postgres_exporter-${POSTGRES_EXPORTER_VERSION}.${ARCH}.tar.gz" \
  "postgres_exporter-${POSTGRES_EXPORTER_VERSION}.${ARCH}.tar.gz" \
  "postgres_exporter" postgres_exporter

install_tar_binary \
  "https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.${ARCH}.tar.gz" \
  "alertmanager-${ALERTMANAGER_VERSION}.${ARCH}.tar.gz" \
  "alertmanager" alertmanager

install -d -o prometheus -g prometheus /etc/prometheus /etc/prometheus/rules /etc/prometheus/targets /var/lib/prometheus
install -d -o alertmanager -g alertmanager /etc/alertmanager /var/lib/alertmanager
install -d -o blackbox_exporter -g blackbox_exporter /etc/blackbox_exporter
install -d -o grafana -g grafana /var/lib/grafana/dashboards 2>/dev/null || true

install -m 0644 /root/config/prometheus/prometheus.yml /etc/prometheus/prometheus.yml
install -m 0644 /root/config/prometheus/rules/*.yml /etc/prometheus/rules/
cp -a targets/. /etc/prometheus/targets/

install -m 0644 config/blackbox/blackbox.yml /etc/blackbox_exporter/blackbox.yml

install -m 0644 /root/config/alertmanager/alertmanager.yml.example /etc/alertmanager/alertmanager.yml
chown alertmanager:alertmanager /etc/alertmanager/alertmanager.yml

install -d /etc/grafana/provisioning/datasources /etc/grafana/provisioning/dashboards
install -m 0644 /root/config/grafana/datasources/prometheus.yml /etc/grafana/provisioning/datasources/prometheus.yml
install -m 0644 /root/config/grafana/dashboards/dashboards.yml /etc/grafana/provisioning/dashboards/dashboards.yml
install -m 0644 /root/config/grafana/dashboards/kong-overview.json /var/lib/grafana/dashboards/kong-overview.json 2>/dev/null || true

install -m 0644 /root/systemd/prometheus.service /etc/systemd/system/prometheus.service
install -m 0644 /root/systemd/alertmanager.service /etc/systemd/system/alertmanager.service
install -m 0644 /root/systemd/kong-observability.target /etc/systemd/system/kong-observability.target
install -m 0644 /root/exporters/node/node_exporter.service /etc/systemd/system/node_exporter.service
install -m 0644 /root/exporters/blackbox/blackbox_exporter.service /etc/systemd/system/blackbox_exporter.service
install -m 0644 /root/exporters/postgres/postgres_exporter.service /etc/systemd/system/postgres_exporter.service

systemctl daemon-reload
systemctl enable --now prometheus
systemctl enable --now alertmanager
systemctl enable --now node_exporter
systemctl enable --now blackbox_exporter
systemctl enable --now grafana-server

echo
echo "Monitoring binaries and services installed."
echo "Configure /etc/default/postgres_exporter before enabling postgres_exporter."
echo "Run: ./scripts/validate.sh"
echo "Run: ./scripts/healthcheck.sh"
