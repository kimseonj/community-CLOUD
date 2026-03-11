#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

STACK="${1:-}"
ACTION="${2:-help}"
SERVICE="${3:-}"

STACKS=("app" "mysql" "redis" "monitoring")

print_usage() {
  cat <<'EOF'
Usage:
  ./scripts/stack.sh <stack> <action> [service]

Stacks:
  app | mysql | redis | monitoring

Actions:
  bootstrap  Create missing env files from *.env.example
  up         docker compose up -d [service]
  down       docker compose down
  restart    docker compose up -d --force-recreate [service]
  ps         docker compose ps
  logs       docker compose logs -f [service]
  pull       docker compose pull [service]
  config     docker compose config
  help       Show this help

Examples:
  ./scripts/stack.sh app bootstrap
  ./scripts/stack.sh app up
  ./scripts/stack.sh monitoring logs grafana
EOF
}

contains_stack() {
  local item
  for item in "${STACKS[@]}"; do
    if [ "$item" = "$1" ]; then
      return 0
    fi
  done
  return 1
}

ensure_file() {
  local stack_dir="$1"
  local target_file="$2"
  local example_file="$3"
  local target_path="$stack_dir/$target_file"
  local example_path="$stack_dir/$example_file"

  if [ ! -f "$example_path" ]; then
    echo "[error] missing example file: $example_path" >&2
    exit 1
  fi

  if [ -f "$target_path" ]; then
    echo "[skip] already exists: $target_path"
    return
  fi

  cp "$example_path" "$target_path"
  echo "[create] $target_path"
}

bootstrap_stack() {
  local stack="$1"
  local stack_dir="$DOCKER_ROOT/$stack"

  case "$stack" in
    app)
      ensure_file "$stack_dir" ".env" ".env.example"
      ensure_file "$stack_dir" "backend.env" "backend.env.example"
      ensure_file "$stack_dir" "alloy.env" "alloy.env.example"
      ensure_file "$stack_dir" "deploy.env" "deploy.env.example"
      ;;
    mysql|redis|monitoring)
      ensure_file "$stack_dir" ".env" ".env.example"
      ;;
    *)
      echo "[error] unsupported stack: $stack" >&2
      exit 1
      ;;
  esac
}

run_compose() {
  local stack="$1"
  shift
  local stack_dir="$DOCKER_ROOT/$stack"

  (
    cd "$stack_dir"
    docker compose "$@"
  )
}

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "[error] docker command not found" >&2
    exit 1
  fi
}

if [ "$STACK" = "" ] || [ "$STACK" = "help" ] || [ "$STACK" = "-h" ] || [ "$STACK" = "--help" ]; then
  print_usage
  exit 0
fi

if ! contains_stack "$STACK"; then
  echo "[error] invalid stack: $STACK" >&2
  print_usage
  exit 1
fi

case "$ACTION" in
  bootstrap)
    bootstrap_stack "$STACK"
    ;;
  up)
    require_docker
    if [ -n "$SERVICE" ]; then
      run_compose "$STACK" up -d "$SERVICE"
    else
      run_compose "$STACK" up -d
    fi
    ;;
  down)
    require_docker
    run_compose "$STACK" down
    ;;
  restart)
    require_docker
    if [ -n "$SERVICE" ]; then
      run_compose "$STACK" up -d --force-recreate "$SERVICE"
    else
      run_compose "$STACK" up -d --force-recreate
    fi
    ;;
  ps)
    require_docker
    run_compose "$STACK" ps
    ;;
  logs)
    require_docker
    if [ -n "$SERVICE" ]; then
      run_compose "$STACK" logs -f "$SERVICE"
    else
      run_compose "$STACK" logs -f
    fi
    ;;
  pull)
    require_docker
    if [ -n "$SERVICE" ]; then
      run_compose "$STACK" pull "$SERVICE"
    else
      run_compose "$STACK" pull
    fi
    ;;
  config)
    require_docker
    run_compose "$STACK" config
    ;;
  help|-h|--help)
    print_usage
    ;;
  *)
    echo "[error] invalid action: $ACTION" >&2
    print_usage
    exit 1
    ;;
esac
