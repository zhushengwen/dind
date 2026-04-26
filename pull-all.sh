#!/bin/bash

echo "Pulling dind images from registry..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

REGISTRY="registry.cn-hangzhou.aliyuncs.com/skillup/dind"

# Array of languages
languages=("base" "rust" "python" "node" "golang" "java")

# Pull and tag each image
failed=0
for lang in "${languages[@]}"; do
    echo -e "${BLUE}[${lang}] Pulling ${REGISTRY}:${lang}...${NC}"
    docker pull ${REGISTRY}:${lang}
    if [ $? -eq 0 ]; then
        docker tag ${REGISTRY}:${lang} dind:${lang}
        echo -e "${GREEN}[${lang}] ✓ Successfully pulled and tagged dind:${lang}${NC}"
    else
        echo -e "${RED}[${lang}] ✗ Pull failed${NC}"
        ((failed++))
    fi
    echo ""
done

echo ""
if [ $failed -eq 0 ]; then
    echo -e "${GREEN}All images pulled successfully!${NC}"
    echo ""
    echo "Available images:"
    docker images | grep dind
else
    echo -e "${RED}${failed} image(s) failed to pull${NC}"
    exit 1
fi