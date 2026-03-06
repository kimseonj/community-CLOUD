# Monitoring Stack

## Start

```bash
git clone <REPO_URL> community-CLOUD
cd /Users/kimsj/kakao-tech/community/community-CLOUD/V1/docker/monitoring
cp .env.example .env
docker compose up -d
```

## Endpoints

- Grafana: `http://<MONITORING_SERVER_PUBLIC_IP>:3000`
- Prometheus: `http://<MONITORING_SERVER_PUBLIC_IP>:9090`
- Loki push API: `http://<MONITORING_SERVER_PRIVATE_IP>:3100/loki/api/v1/push`

## Grafana Login

- ID: `admin`
- PW: `admin1234`

## Stop

```bash
docker compose down
```

## Notes

- Grafana and Prometheus data are persisted in Docker volumes.
- Loki data are persisted in Docker volumes.
- Change Grafana admin password in `.env` before production use.
- Current `prometheus/prometheus.yml` scrapes `node-exporter` and `cadvisor` containers in the same monitoring compose stack.
- Prometheus enables remote-write receiver for Alloy (`/api/v1/write`).
- App, MySQL, and Redis metrics are expected to be pushed from each EC2 Alloy via remote-write.
- App, MySQL, and Redis logs are expected to be pushed from each EC2 Alloy to Loki.
- Grafana auto-loads:
  - Prometheus datasource
  - Loki datasource
  - `Community Backend Performance` dashboard
  - `Community Backend Error Logs` dashboard

## Quick Validation

1. Start monitoring stack.
2. Start app stack with:
   - `PROM_REMOTE_WRITE_URL=http://<MONITORING_PRIVATE_IP>:9090/api/v1/write`
   - `LOKI_WRITE_URL=http://<MONITORING_PRIVATE_IP>:3100/loki/api/v1/push`
3. Start MySQL stack with the same monitoring URLs in `V1/docker/mysql/.env`.
4. Start Redis stack with the same monitoring URLs in `V1/docker/redis/.env`.
5. Open Grafana and verify:
   - dashboard `Community/Community Backend Performance` has data.
   - dashboard `Community/Community Backend Error Logs` shows error logs.

## Server layout

- Monitoring EC2 only needs `V1/docker/monitoring`
- App EC2 only needs `V1/docker/app`
- MySQL EC2 only needs `V1/docker/mysql`
- Redis EC2 only needs `V1/docker/redis`
