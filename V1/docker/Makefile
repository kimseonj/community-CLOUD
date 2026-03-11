SHELL := /bin/bash
STACK ?= app
SERVICE ?=
STACK_SCRIPT := ./scripts/stack.sh

.PHONY: help bootstrap up down restart ps logs pull config

help:
	@echo "Usage: make <target> STACK=<app|mysql|redis|monitoring> [SERVICE=<service>]"
	@echo ""
	@echo "Targets:"
	@echo "  bootstrap  Create missing env files from examples"
	@echo "  up         Start stack (docker compose up -d)"
	@echo "  down       Stop stack"
	@echo "  restart    Recreate stack or one service"
	@echo "  ps         Show running containers"
	@echo "  logs       Follow logs (optionally one service)"
	@echo "  pull       Pull images"
	@echo "  config     Render docker compose config"
	@echo ""
	@echo "Examples:"
	@echo "  make bootstrap STACK=app"
	@echo "  make up STACK=monitoring"
	@echo "  make logs STACK=app SERVICE=backend"

bootstrap:
	@$(STACK_SCRIPT) $(STACK) bootstrap

up:
	@$(STACK_SCRIPT) $(STACK) up $(SERVICE)

down:
	@$(STACK_SCRIPT) $(STACK) down

restart:
	@$(STACK_SCRIPT) $(STACK) restart $(SERVICE)

ps:
	@$(STACK_SCRIPT) $(STACK) ps

logs:
	@$(STACK_SCRIPT) $(STACK) logs $(SERVICE)

pull:
	@$(STACK_SCRIPT) $(STACK) pull $(SERVICE)

config:
	@$(STACK_SCRIPT) $(STACK) config
