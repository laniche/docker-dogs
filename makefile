
.DEFAULT_GOAL: all
.PHONY: all stop start test

# -----------------------------------------------------------------------------

all: stop build start test
	@echo ""

stop: dumpdb
	@docker-compose down

build: stop
	@docker-compose build --no-cache

start: stop build
	@docker-compose up -d

test:
	@bash scripts/testurls.sh

dumpdb:
	@docker exec labdocker_database_1 sh -c 'exec mysqldump docker_dev -uroot -p"docker"' > database/dump.sql

