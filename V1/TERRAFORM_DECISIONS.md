# Terraform V1 결정 문서

이 문서는 V1 인프라를 Terraform으로 만들기 전에 **결정해야 할 항목**을 빠짐없이 정리한 문서입니다.

## 1) 현재 확정된 요구사항

아래는 이미 확정된 사항입니다.

- VPC는 public subnet 기반으로 구성
- EC2 인스턴스 3대 생성
- OS: Ubuntu Linux
- 인스턴스 타입: `t4g.small` (ARM64)
- EC2 Name 태그: `app`, `monitoring`, `db`
- SSH 키페어(Pem) 1개 생성
- 기존 AMI는 없음 (직접 선택 필요)
- ECR 리포지토리 2개 필요
  - `backend`
  - `frontend`
- IAM Role 필요
  - EC2가 ECR 이미지 pull 가능해야 함
  - GitHub Actions가 ECR push 가능해야 함
- 보안그룹(SG)
  - `app`: 8080, 22, 80, 443 오픈 필수
  - `monitoring`, `db`: 상세 정책 미정 (본 문서에서 제안)

---

## 2) 반드시 사용자 결정이 필요한 항목 (의사결정 리스트)

아래 항목은 Terraform 코드 작성 전에 사용자 선택이 필요합니다.

### A. 리전/계정/네이밍

1. AWS 리전
- 예: `ap-northeast-2`, `us-east-1`

2. 프로젝트 Prefix/환경명
- 예: `community-v1`, `dev`, `prod`
- 리소스 이름 충돌 방지를 위해 필요

3. 공통 태그 정책
- 예: `Project`, `Environment`, `Owner`, `ManagedBy=Terraform`

### B. 네트워크(VPC/Subnet)

4. VPC CIDR
- 예: `10.0.0.0/16`

5. Public Subnet CIDR
- 1개만 쓸지, 다중 AZ로 2~3개 쓸지 결정 필요
- 예: `10.0.1.0/24`, `10.0.2.0/24`

6. AZ 전략
- 단일 AZ vs 다중 AZ

7. Internet Gateway / Route Table 구성 방식
- 기본적으로 public subnet이면 IGW + `0.0.0.0/0` 라우트 필요

8. 퍼블릭 IP 부여 방식
- EC2마다 `associate_public_ip_address = true` 여부

### C. EC2 상세

9. Ubuntu AMI 선택 기준
- **중요:** `t4g.small`은 ARM64이므로, Ubuntu **ARM64 AMI**를 써야 함
- Ubuntu 버전 (22.04 LTS / 24.04 LTS)

10. 각 인스턴스 용도 확정
- `app`, `monitoring`, `db` 각각 어떤 프로세스/컨테이너 운영할지

11. 루트 볼륨 크기/타입/암호화
- 예: gp3 20GiB, 암호화 활성화

12. SSH 접속 허용 대역
- 현재 app 22포트 오픈 요구 있음
- 권장: 내 고정 공인IP만 허용 (`x.x.x.x/32`)

13. User Data(부팅 스크립트) 사용 여부
- Docker 설치, CloudWatch Agent 설치, 초기 설정 자동화 여부

### D. 보안그룹(SG)

14. `app` SG 인바운드 소스 제한
- 80/443: 전세계(`0.0.0.0/0`) 허용 여부
- 8080: 전세계 공개 vs 특정 대역/ALB만 허용
- 22: 운영자 IP만 허용 권장

15. `monitoring` SG 정책 확정
- 제안 인바운드:
  - 22: 운영자 IP
  - 3000(Grafana): 운영자IP/VPN만
  - 9090(Prometheus): 내부망(app/monitoring SG)만
- 제안 아웃바운드: 필요 범위만

16. `db` SG 정책 확정
- 제안 인바운드:
  - 22: 운영자 IP (또는 비활성)
  - DB 포트(예: 5432/3306): `app` SG에서만 허용
- 절대 비권장: DB 포트를 `0.0.0.0/0` 공개

17. 보안강화 옵션
- IMDSv2 강제
- 불필요 egress 제한 여부

### E. ECR

18. ECR 리포지토리 옵션
- 이미지 태그 변경 허용 여부 (mutable/immutable)
- 이미지 스캔 활성화 여부
- KMS 암호화 키 사용 여부
- 라이프사이클 정책(예: 최근 30개 태그만 유지)

19. 리포지토리 URI 표준
- 예: `${account}.dkr.ecr.${region}.amazonaws.com/backend`

### F. IAM (EC2/ECR/GitHub Actions)

20. EC2용 IAM Role 권한 범위
- 최소권한 권장: ECR pull 관련 read 권한만

21. GitHub Actions OIDC 연동 여부
- 권장: Access Key 대신 OIDC로 AssumeRole

22. GitHub Actions IAM Role 신뢰 정책
- 허용할 GitHub org/repo
- 허용 브랜치/환경(`sub` claim) 조건

23. GitHub Actions Role 권한
- ECR push에 필요한 최소 권한만 부여

### G. 운영/거버넌스

24. Terraform 상태 관리
- 로컬 state vs S3 + DynamoDB lock (권장: 원격)

25. 환경 분리 전략
- V1 단일 환경만 운영할지, `dev/stage/prod` 분리할지

26. 로그/모니터링
- CloudWatch Logs/Metric/Alarm 도입 범위

27. 백업 정책
- DB 데이터 백업 방식(EBS snapshot 주기 등)

---

## 3) monitoring / db SG 제안안 (초안)

요청하신 "monitoring, db는 알아서 결정"에 대한 기본 안전안입니다.

### monitoring SG (제안)

- Inbound
  - 22/tcp: `운영자 고정 IP(/32)`
  - 3000/tcp (Grafana): `운영자 고정 IP(/32)` 또는 VPN 대역
  - 9090/tcp (Prometheus): `app SG`, `monitoring SG`에서만
- Outbound
  - 443/tcp: 인터넷(패키지/업데이트)
  - 필요 시 내부 통신 허용

### db SG (제안)

- Inbound
  - 22/tcp: `운영자 고정 IP(/32)` (가능하면 비활성 권장)
  - 5432/tcp(PostgreSQL) 또는 3306/tcp(MySQL): `app SG`에서만
- Outbound
  - 기본 제한(필요 목적지로만)

---

## 4) 구현 시 주의사항

1. `t4g.small` + Ubuntu는 ARM64 AMI 필수
2. ECR 이미지를 EC2에서 pull하려면 인스턴스 프로파일(Role) 연결 필요
3. GitHub Actions는 OIDC 기반 AssumeRole 권장 (장기 Access Key 지양)
4. DB를 public subnet에 두는 것은 보안상 비권장
- 현재 요구사항은 public subnet 기반이므로, 최소한 SG를 엄격히 제한해야 함

---

## 5) 다음 단계 (Terraform 코드 작성 전 확정 필요)

아래만 먼저 확정하면 코드 작성 시작 가능:

- AWS 리전
- VPC/Subnet CIDR
- SSH 허용 IP 대역
- DB 엔진/포트(5432 또는 3306)
- GitHub org/repo/브랜치(OCI Role 신뢰정책용)
- Terraform state 저장 방식(로컬 vs S3)
