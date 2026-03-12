# App Runtime (Nginx + Backend + Frontend + Alloy)

## First-time setup

```bash
git clone <REPO_URL> community-CLOUD
cd /Users/kimsj/kakao-tech/community/community-CLOUD/V1/docker/app
cp .env.example .env
cp backend.env.example backend.env
cp alloy.env.example alloy.env
cp deploy.env.example deploy.env
cp frontend.env.example frontend.env
```

Edit files by ownership:
- `.env`: image URI only (`BACKEND_IMAGE`, `FRONTEND_IMAGE`)
- `backend.env`: backend runtime/app secrets
- `frontend.env`: frontend runtime values (ex. `API_BASE_URL`)
- `alloy.env`: Alloy scrape/remote-write/Loki settings
- `deploy.env`: deploy script/AWS account settings

Set `ALLOY_SPRING_TARGET` in `alloy.env` based on backend runtime:
- backend in compose: `backend:8080`
- backend directly on host EC2: `host.docker.internal:8080`
- monitoring server:
  - `PROM_REMOTE_WRITE_URL=http://<MONITORING_PRIVATE_IP>:9090/api/v1/write`
  - `LOKI_WRITE_URL=http://<MONITORING_PRIVATE_IP>:3100/loki/api/v1/push`

## Start all services

```bash
docker compose up -d --build
```

- Nginx listens on `80`
- Nginx -> `backend:8080`, `frontend:3000` via Docker network service names
- Alloy scrapes `${ALLOY_SPRING_TARGET}/api/actuator/prometheus` and forwards metrics to monitoring Prometheus (`alloy.env`)
- Alloy also scrapes local `node-exporter` and `cadvisor` containers and forwards host/container metrics to monitoring Prometheus
- Alloy also reads Docker json logs and pushes them to Loki (`LOKI_WRITE_URL`)

## Deploy with ECR tag

```bash
./deploy.sh all latest
```

### Deploy only backend

```bash
./deploy.sh backend latest
```

### Deploy only frontend

```bash
./deploy.sh frontend latest
```

## Clone-and-run model

- App EC2 only needs this directory: `V1/docker/app`
- Run the monitoring stack separately on the monitoring EC2 from `V1/docker/monitoring`
- Set MySQL and Redis addresses in `backend.env` to each instance's private IP or internal DNS name
