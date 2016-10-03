
.DEFAULT_GOAL: all
.PHONY: all clean build install

# -----------------------------------------------------------------------------

all: build
	@echo "---Complete !---"

build:
	@docker-compose down \
		&& docker-compose build --no-cache --force-rm \
		&& docker-compose up -d \
		&& bash scripts/testurls.sh