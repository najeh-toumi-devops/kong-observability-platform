#!/usr/bin/env bash
set -euo pipefail

KONG_CONF="${KONG_CONF:-/etc/kong/kong.conf}"

if [[ ! -f "$KONG_CONF" ]]; then
  echo "Kong configuration not found: $KONG_CONF"
  exit 1
fi

if grep -Eq '^[[:space:]]*status_listen[[:space:]]*=' "$KONG_CONF"; then
  sed -i 's|^[[:space:]]*status_listen[[:space:]]*=.*|status_listen = 127.0.0.1:8007|' "$KONG_CONF"
else
  printf '\nstatus_listen = 127.0.0.1:8007\n' >> "$KONG_CONF"
fi

kong check "$KONG_CONF"
systemctl restart kong

curl -fsS http://127.0.0.1:8007/ >/dev/null
curl -fsS http://127.0.0.1:8007/metrics >/dev/null

echo "Kong Status API and metrics endpoint are healthy."
