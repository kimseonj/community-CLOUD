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
    monitoring/            # monitoring server compose files
    mysql/                 # db server compose files
```

## Notes

- `terraform/`에는 인프라 코드(VPC, SG, EC2, IAM, ECR)를 둡니다.
- `docker/mysql/`은 DB 서버 EC2에서 실행할 Compose 파일입니다.
- `docker/monitoring/`은 모니터링 서버 EC2에서 실행할 Compose 파일입니다.

## Current mapping

- Monitoring compose currently exists at: `/Users/kimsj/kakao-tech/community/community-CLOUD/V1/monitoring`
- If needed, move it into: `/Users/kimsj/kakao-tech/community/community-CLOUD/V1/docker/monitoring`
