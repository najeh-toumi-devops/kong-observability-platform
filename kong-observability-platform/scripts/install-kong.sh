#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

apt-get update
apt-get install -y curl gnupg lsb-release apt-transport-https

curl -1sLf \
  "https://packages.konghq.com/public/gateway-316/gpg.998DFF461A62FF7C.key" \
  | gpg --dearmor \
  > /usr/share/keyrings/kong-gateway-316-archive-keyring.gpg

curl -1sLf \
  "https://packages.konghq.com/public/gateway-316/config.deb.txt?distro=debian&codename=$(lsb_release -sc)" \
  > /etc/apt/sources.list.d/kong-gateway-316.list

apt-get update
apt-get install -y kong

echo "Kong installed. Configure PostgreSQL before starting it."
kong version
