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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

load_tls_cert_env() {
  local env_file="./.env"
  local primary_domain="${CERTBOT_PRIMARY_DOMAIN:-}"

  if [ -z "$primary_domain" ] && [ -f "$env_file" ]; then
    primary_domain="$(grep -E '^CERTBOT_PRIMARY_DOMAIN=' "$env_file" | tail -n 1 | cut -d '=' -f 2- | tr -d '\"' || true)"
  fi

  if [ -z "$primary_domain" ] && [ -z "${CERTBOT_DOMAINS:-}" ] && [ -f "$env_file" ]; then
    CERTBOT_DOMAINS="$(grep -E '^CERTBOT_DOMAINS=' "$env_file" | tail -n 1 | cut -d '=' -f 2- | tr -d '\"' || true)"
  fi

  if [ -z "$primary_domain" ] && [ -n "${CERTBOT_DOMAINS:-}" ]; then
    primary_domain="${CERTBOT_DOMAINS%%,*}"
  fi

  if [ -z "$primary_domain" ]; then
    return 0
  fi

  if [ -f "/etc/letsencrypt/live/$primary_domain/fullchain.pem" ] && [ -f "/etc/letsencrypt/live/$primary_domain/privkey.pem" ]; then
    export TLS_SERVER_NAME="$primary_domain"
    export TLS_CERT_PATH="/etc/letsencrypt/live/$primary_domain/fullchain.pem"
    export TLS_KEY_PATH="/etc/letsencrypt/live/$primary_domain/privkey.pem"
    echo "Use Let's Encrypt cert for $primary_domain"
  fi
}

if [ "$COMPONENT" = "backend" ] || [ "$COMPONENT" = "frontend" ] || [ "$COMPONENT" = "all" ] || [ "$COMPONENT" = "nginx" ]; then
  AWS_REGION="${AWS_REGION:-ap-northeast-2}"
  AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:?AWS_ACCOUNT_ID is required}"
  BACK_REPOSITORY="${BACK_REPOSITORY:-community-back}"
  FRONT_REPOSITORY="${FRONT_REPOSITORY:-community-front}"

  ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

  aws ecr get-login-password --region "$AWS_REGION" \
    | docker login --username AWS --password-stdin "$ECR_REGISTRY"

  export BACKEND_IMAGE="${ECR_REGISTRY}/${BACK_REPOSITORY}:${TAG}"
  export FRONTEND_IMAGE="${ECR_REGISTRY}/${FRONT_REPOSITORY}:${TAG}"
fi

case "$COMPONENT" in
  backend)
    docker compose pull backend
    docker compose up -d --force-recreate backend
    ;;
  frontend)
    docker compose pull frontend
    docker compose up -d --force-recreate frontend
    ;;
  nginx)
    load_tls_cert_env
    docker compose up -d --build --force-recreate nginx
    ;;
  certbot)
    docker compose --profile ssl run --rm certbot
    load_tls_cert_env
    docker compose up -d --force-recreate nginx
    ;;
  all)
    docker compose pull backend frontend
    docker compose pull alloy || true
    load_tls_cert_env
    docker compose up -d --build --force-recreate nginx backend frontend alloy
    ;;
  *)
    echo "Usage: $0 [backend|frontend|nginx|certbot|all] [tag]"
    exit 1
    ;;
esac

# Show current running images

docker compose ps
