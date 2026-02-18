# Monitoring Stack

## Start

```bash
cd /Users/kimsj/kakao-tech/community/community-CLOUD/V1/docker/monitoring
docker compose up -d
```

## Endpoints

- Grafana: `http://<MONITORING_SERVER_PUBLIC_IP>:3000`
- Prometheus: `http://<MONITORING_SERVER_PUBLIC_IP>:9090`

## Grafana Login

- ID: `admin`
- PW: `admin1234`

## Stop

```bash
docker compose down
```

## Notes

- Grafana and Prometheus data are persisted in Docker volumes.
- Change Grafana admin password before production use.
- Current `prometheus/prometheus.yml` scrapes `node-exporter` and `cadvisor` containers in the same monitoring compose stack.
- Prometheus enables remote-write receiver for Alloy (`/api/v1/write`).
- App(Spring) metrics are expected to be pushed from app EC2 Alloy via remote-write.
- Grafana auto-loads:
  - Prometheus datasource
  - `Community Backend Performance` dashboard

## Quick Validation

1. Start monitoring stack.
2. Start app stack with `PROM_REMOTE_WRITE_URL=http://<MONITORING_PRIVATE_IP>:9090/api/v1/write`.
3. Open Grafana and verify dashboard `Community/Community Backend Performance` has data.

## Separate EC2 Access (App EC2 + Monitoring EC2)

- Terraform creates both EC2 in the same VPC and same public subnet.
- Monitoring SG opens `22`, `3000`, `9090`.
- App SG allows access from Monitoring SG to `9100` (node-exporter) and `8080` (cadvisor) when those exporters run on app EC2.

If you run exporters on the **app EC2**, set Prometheus target to app private IP:

```yaml
scrape_configs:
  - job_name: app-node-exporter
    static_configs:
      - targets: ["<APP_PRIVATE_IP>:9100"]

  - job_name: app-cadvisor
    static_configs:
      - targets: ["<APP_PRIVATE_IP>:8080"]
```

Example: if app private IP is `10.0.1.23`, use `10.0.1.23:9100`, `10.0.1.23:8080`.
