.PHONY: image-base image-node image-python image-go image-rust image-full images image-list

# Image presets
IMAGES := base node python go rust full
IMAGE_PREFIX := optio

# Build the base image (dependency for all others)
image-base:
	docker build -t $(IMAGE_PREFIX)-base:latest -f images/base.Dockerfile .

# Language-specific images (each depends on base)
image-node: image-base
	docker build -t $(IMAGE_PREFIX)-node:latest -f images/node.Dockerfile .

image-python: image-base
	docker build -t $(IMAGE_PREFIX)-python:latest -f images/python.Dockerfile .

image-go: image-base
	docker build -t $(IMAGE_PREFIX)-go:latest -f images/go.Dockerfile .

image-rust: image-base
	docker build -t $(IMAGE_PREFIX)-rust:latest -f images/rust.Dockerfile .

# Full image (depends on base, includes all languages)
image-full: image-base
	docker build -t $(IMAGE_PREFIX)-full:latest -f images/full.Dockerfile .

# Build all images and tag default
images: image-base image-node image-python image-go image-rust image-full
	docker tag $(IMAGE_PREFIX)-base:latest $(IMAGE_PREFIX)-agent:latest

# List built optio images
image-list:
	@docker images --filter "reference=$(IMAGE_PREFIX)-*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
