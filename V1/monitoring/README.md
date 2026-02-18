# Monitoring Stack

## Start

```bash
cd /Users/kimsj/kakao-tech/community/community-CLOUD/V1/monitoring
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
- Prometheus enables remote-write receiver for Alloy (`/api/v1/write`).
- App(Spring) metrics are expected to be pushed from app EC2 Alloy via remote-write.
- Grafana auto-loads:
  - Prometheus datasource
  - `Community Backend Performance` dashboard
