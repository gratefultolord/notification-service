# Loading .env
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Go params
GOCMD = go
GOTEST = $(GOCMD) test
GOLINT = golangci-lint run
BINARY_NOTIFIER = bin/notifier
BINARY_WORKER = bin/worker

# Docker Compose
DC = docker-compose

# Building binaries
build:
	@echo "Building notifier..."
	$(GOCMD) build -o $(BINARY_NOTIFIER) ./cmd/notifier
	@echo "Building worker..."
	$(GOCMD) build -o $(BINARY_WORKER) ./cmd/worker

# Tests
test:
	@echo "Running tests..."
	$(GOTEST) ./... -v -cover	

# Linters
lint:
	@echo "Running linters..."
	$(GOLINT) ./...

# Running in local environment
run-notifier:
	@echo "Running notifier..."
	$(BINARY_NOTIFIER)

run_worker:
	@echo "Running worker..."
	$(BINARY_WORKER)

# Docker Compose commands
up:
	$(DC) up --build

down:
	$(DC) down

logs:
	$(DC) logs -f

# Migrations
migrate-up:
	docker exec -i postgres sh -c "cd /scripts && ./migrate -path . -database \"postgres://${DB_USER}:${DB_PASSWORD}@localhost:5432/${DB_NAME}?sslmode=disable\" up"

migrate-down:
	docker exec -i postgres sh -c "cd /scripts && ./migrate -path . -database \"postgres://${DB_USER}:${DB_PASSWORD}@localhost:5432/${DB_NAME}?sslmode=disable\" down"

# Cleaning binaries
clean:
	rm -rf bin/*

# Full build + tests + lint
all: clean build test lint
	@echo "Build, test and lint completed"