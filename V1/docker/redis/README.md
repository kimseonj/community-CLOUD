# Redis Runtime (Redis + Alloy + Exporters)

## Setup

```bash
git clone <REPO_URL> community-CLOUD
cd V1/docker/redis
cp .env.example .env
# .env 파일에서 REDIS_PASSWORD와 monitoring URL 설정
```

## Start

```bash
docker compose up -d
```

## Check

```bash
docker compose ps
docker exec community-redis redis-cli ping
```

## Notes

- This instance also runs `redis-exporter`, `node-exporter`, `cadvisor`, and `alloy`.
- Redis metrics and Docker logs are forwarded to the monitoring EC2.
