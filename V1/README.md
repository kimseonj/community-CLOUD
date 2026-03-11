# V1 Structure (Recommended)

```text
V1/
  README.md
  TERRAFORM_DECISIONS.md
  terraform/
    providers.tf
    versions.tf
    variables.tf
    main.tf
    outputs.tf
    terraform.tfvars.example
  docker/
    app/                   # App EC2 - Backend + Frontend + Nginx + Alloy + exporters
    mysql/                 # MySQL EC2 - MySQL + Alloy + exporters
    redis/                 # Redis EC2 - Redis + Alloy + exporters
    monitoring/            # Monitoring EC2 - Prometheus + Grafana + Loki
    scripts/stack.sh       # stack 공통 실행 스크립트
    Makefile               # make 진입점
  docs/
    INFRA_TERRAFORM_V1.md  # Terraform 인프라 문서
```

## Notes

- `terraform/`에는 인프라 코드(VPC, SG, EC2, IAM, ECR)를 둡니다.
- `docker/app/`은 App EC2에서 실행할 앱 런타임 + 모니터링 에이전트 Compose 파일입니다.
- `docker/mysql/`은 MySQL EC2에서 실행할 MySQL + 모니터링 에이전트 Compose 파일입니다.
- `docker/redis/`는 Redis EC2에서 실행할 Redis + 모니터링 에이전트 Compose 파일입니다.
- `docker/monitoring/`은 Monitoring EC2에서 실행할 Prometheus + Grafana + Loki Compose 파일입니다.
- `docker/Makefile`로 `make bootstrap STACK=<stack>`, `make up STACK=<stack>` 형태로 공통 실행합니다.

## 상세 문서

- Docker 운영 가이드: [`V1/docker/README.md`](docker/README.md)
- Docker 셋업 가이드: [`docs/v1/DOCKER_SETUP.md`](../docs/v1/DOCKER_SETUP.md)
- Terraform 인프라 문서: [`V1/docs/INFRA_TERRAFORM_V1.md`](docs/INFRA_TERRAFORM_V1.md)
