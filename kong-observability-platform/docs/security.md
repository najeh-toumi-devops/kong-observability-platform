# Security

## Principles

- Bind administration and metrics endpoints to localhost whenever possible.
- Use dedicated service accounts.
- Use least-privilege PostgreSQL credentials.
- Keep exporter credentials outside Git.
- Restrict Grafana/Prometheus/Alertmanager with firewall rules or an authenticated reverse proxy.
- Validate configuration before reload.
- Review every target added through Git.
- Do not commit private keys, passwords or tokens.

## Sensitive files

```text
/etc/default/postgres_exporter
/etc/alertmanager/alertmanager.yml
/etc/kong/kong.conf
```

may contain environment-specific secrets and should not be copied into the repository with real credentials.
