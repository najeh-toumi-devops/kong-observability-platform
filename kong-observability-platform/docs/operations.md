# Operations

## Reload configuration

```bash
./scripts/validate.sh
./scripts/reload.sh
```

## Service status

```bash
systemctl --failed
systemctl status prometheus alertmanager grafana-server --no-pager
```

## Logs

```bash
journalctl -u prometheus -n 100 --no-pager
journalctl -u alertmanager -n 100 --no-pager
journalctl -u grafana-server -n 100 --no-pager
journalctl -u node_exporter -n 100 --no-pager
journalctl -u blackbox_exporter -n 100 --no-pager
journalctl -u postgres_exporter -n 100 --no-pager
```
