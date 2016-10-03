
.DEFAULT_GOAL: all
.PHONY: all stop start test

# -----------------------------------------------------------------------------

all: stop build start test
	@echo "---Complete !---"

stop:
	@docker-compose down

build: stop
	docker-compose build --no-cache --force-rm

start: stop build
	docker-compose up -d

test:
	bash scripts/testurls.sh