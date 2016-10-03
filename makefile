
.DEFAULT_GOAL: all
.PHONY: all stop start test

# -----------------------------------------------------------------------------

all: stop build start test
	@echo ""

stop:
	@docker-compose down

build: stop
	docker-compose build --no-cache

start: stop build
	docker-compose up -d

test:
	bash scripts/testurls.sh