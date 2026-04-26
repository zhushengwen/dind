#!/bin/bash

echo "Building dind images with programming languages..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Build base dind image first
echo -e "${BLUE}Building base dind image...${NC}"
docker build --secret id=my_secret_var,src=arg.txt -t dind .

# Array of languages and their build args
languages=("rust" "python" "node" "golang" "java")

# Array to store background job PIDs and language names
declare -a pids
declare -a lang_names

echo -e "${BLUE}Starting parallel builds for language variants...${NC}"
echo -e "${YELLOW}Building: ${languages[*]}${NC}"
echo ""

# Build each language variant in parallel
for lang in "${languages[@]}"; do
    (
        echo -e "${BLUE}[${lang}] Starting build...${NC}"
        docker build \
            --secret id=my_secret_var,src=arg.txt \
            --build-arg LANG_TYPE=${lang} \
            -f Dockerfile.multi \
            -t dind:${lang} . > /tmp/dind-build-${lang}.log 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[${lang}] ✓ Successfully built dind:${lang}${NC}"
        else
            echo -e "\033[0;31m[${lang}] ✗ Build failed (check /tmp/dind-build-${lang}.log)${NC}"
            exit 1
        fi
    ) &
    pids+=($!)
    lang_names+=(${lang})
done

# Wait for all background jobs and check their exit status
failed=0
for i in "${!pids[@]}"; do
    wait ${pids[$i]}
    if [ $? -ne 0 ]; then
        ((failed++))
    fi
done

echo ""
if [ $failed -eq 0 ]; then
    echo -e "${GREEN}All images built successfully!${NC}"
    echo ""
    echo "Built images:"
    docker images | grep dind

    # Push all images to registry
    echo ""
    echo -e "${BLUE}Pushing images to registry...${NC}"
    for lang in "${languages[@]}"; do
        echo -e "${BLUE}[${lang}] Tagging and pushing...${NC}"
        docker tag dind:${lang} registry.cn-hangzhou.aliyuncs.com/skillup/dind:${lang}
        docker push registry.cn-hangzhou.aliyuncs.com/skillup/dind:${lang}
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[${lang}] ✓ Successfully pushed registry.cn-hangzhou.aliyuncs.com/skillup/dind:${lang}${NC}"
        else
            echo -e "\033[0;31m[${lang}] ✗ Push failed${NC}"
            ((failed++))
        fi
    done
else
    echo -e "\033[0;31m${failed} image(s) failed to build${NC}"
    exit 1
fi
