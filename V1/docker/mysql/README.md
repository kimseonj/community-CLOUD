# MySQL Runtime (MySQL + Alloy + Exporters)

## 1) Prepare env

```bash
git clone <REPO_URL> community-CLOUD
cd /Users/kimsj/kakao-tech/community/community-CLOUD/V1/docker/mysql
cp .env.example .env
```

Edit `.env` with strong passwords and monitoring URLs.

## 2) Run

```bash
docker compose up -d
```

## 3) Check

```bash
docker compose ps
docker compose logs -f mysql
```

## 4) Stop

```bash
docker compose down
```

## Security

- Keep SG for 3306 open only from app server/security-group.
- Do not expose 3306 to `0.0.0.0/0`.
- This instance also runs Alloy, `mysqld-exporter`, `node-exporter`, and `cadvisor`.
