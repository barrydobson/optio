#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTAINER_REPO="ghcr.io/thetote"
CONTAINER_NAME="optio"
TAG="${1:-latest}"

BASE_IMAGE="${CONTAINER_REPO}/${CONTAINER_NAME}-base:${TAG}"

echo "=== Building Optio Agent Images ==="

# Base image (all others depend on this)
echo "Building optio-base..."
docker build -t "${BASE_IMAGE}" -t "${CONTAINER_REPO}/${CONTAINER_NAME}-agent:${TAG}" -f "${SCRIPT_DIR}/base.Dockerfile" "${ROOT_DIR}"
echo "Using base internal image: ${CONTAINER_REPO}/${CONTAINER_NAME}-base:${TAG}"

# Language-specific images (can be built in parallel)
echo "Building ${CONTAINER_NAME}-node..."
docker build -t "${CONTAINER_REPO}/${CONTAINER_NAME}-node:${TAG}" --build-arg BASE_IMAGE="${BASE_IMAGE}" -f "${SCRIPT_DIR}/node.Dockerfile" "${ROOT_DIR}" &

echo "Building ${CONTAINER_NAME}-go..."
docker build -t "${CONTAINER_REPO}/${CONTAINER_NAME}-go:${TAG}" --build-arg BASE_IMAGE="${BASE_IMAGE}" -f "${SCRIPT_DIR}/go.Dockerfile" "${ROOT_DIR}" &

wait

echo "Building optio-full..."
docker build -t "${CONTAINER_REPO}/${CONTAINER_NAME}-full:${TAG}" --build-arg BASE_IMAGE="${BASE_IMAGE}" -f "${SCRIPT_DIR}/full.Dockerfile" "${ROOT_DIR}"

echo ""
echo "=== Images Built ==="
docker images --filter "reference=${CONTAINER_REPO}/${CONTAINER_NAME}-*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

