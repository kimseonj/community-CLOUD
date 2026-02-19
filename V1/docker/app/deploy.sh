#!/usr/bin/env bash
set -euo pipefail

COMPONENT="${1:-all}"
TAG="${2:-latest}"

DEPLOY_ENV_FILE="${DEPLOY_ENV_FILE:-./deploy.env}"
if [ -f "$DEPLOY_ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$DEPLOY_ENV_FILE"
  set +a
fi

AWS_REGION="${AWS_REGION:-ap-northeast-2}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:?AWS_ACCOUNT_ID is required}"
BACK_REPOSITORY="${BACK_REPOSITORY:-community-back}"
FRONT_REPOSITORY="${FRONT_REPOSITORY:-community-front}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"

export BACKEND_IMAGE="${ECR_REGISTRY}/${BACK_REPOSITORY}:${TAG}"
export FRONTEND_IMAGE="${ECR_REGISTRY}/${FRONT_REPOSITORY}:${TAG}"

case "$COMPONENT" in
  backend)
    docker compose pull backend
    docker compose up -d backend
    ;;
  frontend)
    docker compose pull frontend
    docker compose up -d frontend
    ;;
  nginx)
    docker compose up -d --build nginx
    ;;
  all)
    docker compose pull backend frontend
    docker compose pull alloy || true
    docker compose up -d --build nginx backend frontend alloy
    ;;
  *)
    echo "Usage: $0 [backend|frontend|nginx|all] [tag]"
    exit 1
    ;;
esac

# Show current running images

docker compose ps
