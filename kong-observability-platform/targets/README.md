# Dynamic targets

Targets are intentionally separated from the core Prometheus configuration.

Prometheus watches these files using `file_sd_configs`.

## Add an API

```yaml
- targets:
    - https://api.example.com/health
  labels:
    environment: production
    service: customer-api
    team: platform
```

## Add a Kong instance

```yaml
- targets:
    - 10.10.10.21:8007
  labels:
    environment: production
    cluster: kong-prod
    instance_name: kong-01
```

## Add another environment

Create:

```text
targets/uat/
targets/development/
```

and add the files to the Prometheus file discovery configuration.
