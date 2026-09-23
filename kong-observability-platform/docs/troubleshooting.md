# Troubleshooting

## Prometheus target is DOWN

```bash
curl -v http://127.0.0.1:8007/metrics
curl -v http://127.0.0.1:9100/metrics
curl -v http://127.0.0.1:9115/metrics
curl -v http://127.0.0.1:9187/metrics
```

Then inspect:

```text
http://127.0.0.1:9090/targets
```

## Kong metrics missing

```bash
kong check /etc/kong/kong.conf
systemctl status kong --no-pager
curl -fsS http://127.0.0.1:8007/metrics | grep '^kong_'
```

Check the Prometheus plugin through the Kong Admin API.

## Grafana is empty

Check:

```bash
curl -fsS http://127.0.0.1:9090/api/v1/targets
```

Then verify the Grafana datasource points to:

```text
http://127.0.0.1:9090
```
