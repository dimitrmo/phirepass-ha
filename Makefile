.PHONY: help build run stop clean push logs shell test

# Variables
ADDON_NAME := phirepass
DOCKER_REGISTRY := ghcr.io
DOCKER_USERNAME := $(shell git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
IMAGE_NAME := $(DOCKER_REGISTRY)/$(DOCKER_USERNAME)/$(ADDON_NAME)-ha
VERSION := $(shell cat addon.yaml | grep "^version:" | awk '{print $$2}')
CONTAINER_NAME := phirepass-addon

help:
	@echo "PhirePass Home Assistant Addon - Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make build          - Build the Docker image"
	@echo "  make run            - Run the container locally (foreground, -it --rm)"
	@echo "  make stop           - Stop the running container"
	@echo "  make clean          - Remove the Docker image and container"
	@echo "  make push           - Push image to registry (requires login)"
	@echo "  make logs           - View container logs"
	@echo "  make shell          - Open shell in running container"
	@echo "  make test           - Build and run basic tests"
	@echo "  make rebuild        - Clean and rebuild image"
	@echo ""

build:
	@echo "Building Docker image: $(IMAGE_NAME):$(VERSION)"
	docker build -t $(IMAGE_NAME):$(VERSION) .
	docker tag $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):latest
	@echo "✓ Build complete"

run: build
	@echo "Running container: $(CONTAINER_NAME)"
	docker run -it --rm \
		--name $(CONTAINER_NAME) \
		-p 8080:8080 \
		-v $(PWD)/data:/data \
		$(IMAGE_NAME):$(VERSION)

stop:
	@echo "Stopping container: $(CONTAINER_NAME)"
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true
	@echo "✓ Container stopped"

clean: stop
	@echo "Removing container and image..."
	@docker rm $(CONTAINER_NAME) 2>/dev/null || true
	docker rmi $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):latest 2>/dev/null || true
	@echo "✓ Cleanup complete"

push: build
	@echo "Pushing image to registry..."
	@if [ -z "$(DOCKER_USERNAME)" ]; then \
		echo "Error: Could not determine Docker username"; \
		exit 1; \
	fi
	docker push $(IMAGE_NAME):$(VERSION)
	docker push $(IMAGE_NAME):latest
	@echo "✓ Push complete"

logs:
	@docker logs -f $(CONTAINER_NAME)

shell:
	@docker exec -it $(CONTAINER_NAME) /bin/sh

test: build
	@echo "Running basic container tests..."
	@echo "Testing: Image builds without errors"
	@docker inspect $(IMAGE_NAME):$(VERSION) > /dev/null && echo "✓ Image exists"
	@echo "Testing: Container can start"
	@docker run --rm -v $(PWD)/data:/data $(IMAGE_NAME):$(VERSION) /bin/sh -c "echo 'PhirePass daemon test'" && echo "✓ Container starts successfully"
	@echo "✓ All tests passed"

rebuild: clean build

# Print variables for debugging
info:
	@echo "Build Information:"
	@echo "  Image Name: $(IMAGE_NAME)"
	@echo "  Version: $(VERSION)"
	@echo "  Container Name: $(CONTAINER_NAME)"
	@echo "  Registry: $(DOCKER_REGISTRY)"
