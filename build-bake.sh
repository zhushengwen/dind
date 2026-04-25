#!/bin/bash

set -e

echo "🐳 Building dind images using Docker Buildx Bake (Multi-Stage Builds)..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check if buildx is available
if ! docker buildx version > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Docker Buildx is not available, falling back to build-all.sh${NC}"
    exec ./build-all.sh
fi

# Create buildx builder if it doesn't exist
BUILDER_NAME="dind-builder"
if ! docker buildx ls | grep -q "^${BUILDER_NAME}"; then
    echo -e "${BLUE}Creating buildx builder: ${BUILDER_NAME}${NC}"
    docker buildx create --name ${BUILDER_NAME} --use
else
    docker buildx use ${BUILDER_NAME}
fi

echo ""
echo -e "${BLUE}Building all dind images with Docker Buildx (Multi-Stage Optimization)${NC}"
echo -e "${YELLOW}Features:${NC}"
echo "  ✓ Multi-stage builds (smaller images)"
echo "  ✓ Parallel construction layers"
echo "  ✓ Layer caching optimization"
echo "  ✓ True concurrent builds"
echo ""

# Build using docker-bake.hcl with multi-stage Dockerfile
# Note: buildx bake doesn't support --secret flag, we use build context instead
docker buildx bake \
    --progress=plain

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ All images built successfully with Buildx (Multi-Stage)!${NC}"
    echo ""
    echo "Built images:"
    docker images | grep dind
    echo ""
    echo -e "${BLUE}Performance Tips:${NC}"
    echo "  • Multi-stage builds reduce build time by optimizing layers"
    echo "  • Rust and Go toolchains are isolated in build stages"
    echo "  • Run: docker inspect <image> --format='{{.Size}}' to check size"
else
    echo -e "\033[0;31m❌ Build failed${NC}"
    exit 1
fi
