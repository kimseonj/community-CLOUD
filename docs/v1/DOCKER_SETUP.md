# V1 Docker 구성 가이드

이 문서는 각 EC2에 `community-CLOUD` 레포를 clone한 뒤 필요한 디렉터리만 사용해 서비스를 올리는 방식을 기준으로 정리한다.

## 서버별 디렉터리

```text
Monitoring EC2 -> V1/docker/monitoring
App EC2        -> V1/docker/app
MySQL EC2      -> V1/docker/mysql
Redis EC2      -> V1/docker/redis
```

## 전체 흐름

```text
App EC2
  backend/frontend/nginx + alloy + node-exporter + cadvisor
  -> Prometheus remote_write / Loki push

MySQL EC2
  mysql + mysqld-exporter + alloy + node-exporter + cadvisor
  -> Prometheus remote_write / Loki push

Redis EC2
  redis + redis-exporter + alloy + node-exporter + cadvisor
  -> Prometheus remote_write / Loki push

Monitoring EC2
  prometheus + grafana + loki + node-exporter + cadvisor
```

## 1. Monitoring EC2

```bash
git clone <REPO_URL> community-CLOUD
cd community-CLOUD/V1/docker/monitoring
cp .env.example .env
docker compose up -d
```

`.env`에서 최소한 아래 값을 운영값으로 바꾼다.

| 변수 | 설명 |
|------|------|
| `GRAFANA_ADMIN_USER` | Grafana 관리자 계정 |
| `GRAFANA_ADMIN_PASSWORD` | Grafana 관리자 비밀번호 |

기본 엔드포인트:

| 서비스 | 주소 |
|--------|------|
| Grafana | `http://<MONITORING_PUBLIC_IP>:3000` |
| Prometheus | `http://<MONITORING_PUBLIC_IP>:9090` |
| Loki push | `http://<MONITORING_PRIVATE_IP>:3100/loki/api/v1/push` |

## 2. App EC2

```bash
git clone <REPO_URL> community-CLOUD
cd community-CLOUD/V1/docker/app
cp .env.example .env
cp backend.env.example backend.env
cp alloy.env.example alloy.env
cp deploy.env.example deploy.env
docker compose up -d --build
```

핵심 설정:

| 파일 | 설명 |
|------|------|
| `.env` | `BACKEND_IMAGE`, `FRONTEND_IMAGE` |
| `backend.env` | Spring MySQL/Redis/JWT 설정 |
| `alloy.env` | `ALLOY_SPRING_TARGET`, `PROM_REMOTE_WRITE_URL`, `LOKI_WRITE_URL` |
| `deploy.env` | `AWS_ACCOUNT_ID`, `AWS_REGION` 등 배포 스크립트용 값 |

## 3. MySQL EC2

```bash
git clone <REPO_URL> community-CLOUD
cd community-CLOUD/V1/docker/mysql
cp .env.example .env
docker compose up -d
```

`.env` 주요 항목:

| 변수 | 설명 |
|------|------|
| `MYSQL_ROOT_PASSWORD` | MySQL root 비밀번호 |
| `MYSQL_DATABASE` | 기본 DB 이름 |
| `MYSQL_USER` | 앱용 DB 계정 |
| `MYSQL_PASSWORD` | 앱용 DB 비밀번호 |
| `MYSQL_EXPORTER_USER` | MySQL exporter 계정 |
| `MYSQL_EXPORTER_PASSWORD` | MySQL exporter 비밀번호 |
| `PROM_REMOTE_WRITE_URL` | Monitoring Prometheus remote-write URL |
| `LOKI_WRITE_URL` | Monitoring Loki push URL |

이 Compose는 `mysql`, `mysqld-exporter`, `node-exporter`, `cadvisor`, `alloy`를 함께 올린다.

## 4. Redis EC2

```bash
git clone <REPO_URL> community-CLOUD
cd community-CLOUD/V1/docker/redis
cp .env.example .env
docker compose up -d
```

`.env` 주요 항목:

| 변수 | 설명 |
|------|------|
| `REDIS_PASSWORD` | Redis 비밀번호 |
| `REDIS_PORT` | Redis 포트 |
| `REDIS_MAXMEMORY` | Redis 메모리 제한 |
| `PROM_REMOTE_WRITE_URL` | Monitoring Prometheus remote-write URL |
| `LOKI_WRITE_URL` | Monitoring Loki push URL |

이 Compose는 `redis`, `redis-exporter`, `node-exporter`, `cadvisor`, `alloy`를 함께 올린다.

## 데이터 흐름

### 메트릭

```text
App EC2 / MySQL EC2 / Redis EC2 exporters
  -> Alloy scrape
  -> Prometheus remote_write
  -> Monitoring EC2 Prometheus
  -> Grafana
```

### 로그

```text
Docker json logs on App EC2 / MySQL EC2 / Redis EC2
  -> Alloy file tail
  -> Monitoring EC2 Loki
  -> Grafana
```

## 운영 규칙

- 각 EC2는 레포 전체를 clone하되, 해당 서버에 필요한 `V1/docker/...` 디렉터리만 사용한다.
- 실제 운영값은 `.env`, `backend.env`, `alloy.env`, `deploy.env`에 넣고 example 파일만 커밋한다.
- Monitoring EC2는 `9090`과 `3100`을 App/MySQL/Redis EC2에서 접근 가능하게 열어둬야 한다.

## 빠른 점검

```bash
curl http://<MONITORING_PRIVATE_IP>:9090/-/ready
curl http://<MONITORING_PRIVATE_IP>:3100/ready
docker logs community-alloy
docker logs community-mysql-alloy
docker logs community-redis-alloy
```
