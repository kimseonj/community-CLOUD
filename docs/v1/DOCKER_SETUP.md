# V1 Docker 구성 가이드

이 문서는 각 EC2에서 `git clone` 후 `V1/docker` 공통 진입점(`Makefile`, `scripts/stack.sh`)으로 stack을 올리는 기준을 다룬다.

## 서버별 stack

```text
Monitoring EC2 -> STACK=monitoring
App EC2        -> STACK=app
MySQL EC2      -> STACK=mysql
Redis EC2      -> STACK=redis
```

## 전체 흐름

```text
App / MySQL / Redis EC2
  -> Alloy remote_write
  -> Monitoring EC2 Prometheus
  -> Grafana

App / MySQL / Redis EC2
  -> Alloy log push
  -> Monitoring EC2 Loki
  -> Grafana
```

## 공통 실행 방식

```bash
git clone <REPO_URL> community-CLOUD
cd community-CLOUD/V1/docker

# 예시 파일 기반으로 env 자동 생성 (이미 있으면 skip)
make bootstrap STACK=<app|mysql|redis|monitoring>

# 실행
make up STACK=<app|mysql|redis|monitoring>
```

## 1) Monitoring EC2

```bash
cd community-CLOUD/V1/docker
make bootstrap STACK=monitoring
make up STACK=monitoring
```

`.env` 필수 값:

- `GRAFANA_ADMIN_USER`
- `GRAFANA_ADMIN_PASSWORD`

엔드포인트:

- Grafana: `http://<MONITORING_PUBLIC_IP>:3000`
- Prometheus: `http://<MONITORING_PUBLIC_IP>:9090`
- Loki push: `http://<MONITORING_PRIVATE_IP>:3100/loki/api/v1/push`

## 2) App EC2

```bash
cd community-CLOUD/V1/docker
make bootstrap STACK=app
make up STACK=app
```

`bootstrap` 시 생성 파일:

- `V1/docker/app/.env`
- `V1/docker/app/backend.env`
- `V1/docker/app/frontend.env`
- `V1/docker/app/alloy.env`
- `V1/docker/app/deploy.env`

핵심 설정:

- `.env`: `BACKEND_IMAGE`, `FRONTEND_IMAGE`
  - `backend.env`: Spring DB/Redis/JWT 설정
  - `frontend.env`: frontend runtime 값 (ex. `API_BASE_URL`)
- `alloy.env`: `ALLOY_SPRING_TARGET`, `PROM_REMOTE_WRITE_URL`, `LOKI_WRITE_URL`
- `deploy.env`: ECR 배포 스크립트용 AWS 설정

## 3) MySQL EC2

```bash
cd community-CLOUD/V1/docker
make bootstrap STACK=mysql
make up STACK=mysql
```

`.env` 주요 항목:

- `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`
- `MYSQL_EXPORTER_USER`, `MYSQL_EXPORTER_PASSWORD`
- `PROM_REMOTE_WRITE_URL`, `LOKI_WRITE_URL`

## 4) Redis EC2

```bash
cd community-CLOUD/V1/docker
make bootstrap STACK=redis
make up STACK=redis
```

`.env` 주요 항목:

- `REDIS_PASSWORD`, `REDIS_PORT`, `REDIS_MAXMEMORY`
- `PROM_REMOTE_WRITE_URL`, `LOKI_WRITE_URL`

## 운영 규칙

- Git에는 Compose/설정 템플릿/스크립트만 커밋한다.
- 실제 env/secret 값은 커밋하지 않는다.
- Monitoring EC2는 `9090`, `3100`을 App/MySQL/Redis EC2에서 접근 가능해야 한다.
- App stack은 `BACKEND_IMAGE`, `FRONTEND_IMAGE` pull 권한(ECR 등)이 있어야 정상 실행된다.

## 점검 명령

```bash
cd community-CLOUD/V1/docker
make ps STACK=monitoring
make logs STACK=app SERVICE=alloy
make logs STACK=mysql SERVICE=mysql
make logs STACK=redis SERVICE=redis
```
