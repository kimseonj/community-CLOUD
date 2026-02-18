# App Runtime (Nginx + Backend + Frontend + Alloy)

## First-time setup

```bash
cd /Users/kimsj/kakao-tech/community/community-CLOUD/V1/docker/app
cp .env.example .env
```

Edit `.env` image URIs if needed.
Set `PROM_REMOTE_WRITE_URL` to monitoring Prometheus remote-write endpoint.

## Start all services

```bash
docker compose up -d --build
```

- Nginx listens on `80`
- Nginx -> `backend:8080`, `frontend:3000` via Docker network service names
- Alloy scrapes `backend:8080/api/actuator/prometheus` and forwards metrics to monitoring Prometheus

## Deploy with ECR tag

```bash
AWS_REGION=ap-northeast-2 AWS_ACCOUNT_ID=715760504932 ./deploy.sh all latest
```

### Deploy only backend

```bash
AWS_REGION=ap-northeast-2 AWS_ACCOUNT_ID=715760504932 ./deploy.sh backend latest
```

### Deploy only frontend

```bash
AWS_REGION=ap-northeast-2 AWS_ACCOUNT_ID=715760504932 ./deploy.sh frontend latest
```
