variable "DOCKER_REGISTRY" {
  default = "docker.io"
}

variable "IMAGE_NAME" {
  default = "dind"
}

// Base image target
target "base" {
  dockerfile = "Dockerfile"
  tags = [
    "${DOCKER_REGISTRY}/${IMAGE_NAME}:latest",
  ]
  output = ["type=docker"]
}

// Language-specific targets using multi-stage builds (optimized)
target "rust" {
  dockerfile = "Dockerfile.multistage"
  args = {
    LANG_TYPE = "rust"
  }
  tags = [
    "${DOCKER_REGISTRY}/${IMAGE_NAME}:rust",
  ]
  output = ["type=docker"]
}

target "python" {
  dockerfile = "Dockerfile.multistage"
  args = {
    LANG_TYPE = "python"
  }
  tags = [
    "${DOCKER_REGISTRY}/${IMAGE_NAME}:python",
  ]
  output = ["type=docker"]
}

target "node" {
  dockerfile = "Dockerfile.multistage"
  args = {
    LANG_TYPE = "node"
  }
  tags = [
    "${DOCKER_REGISTRY}/${IMAGE_NAME}:node",
  ]
  output = ["type=docker"]
}

target "golang" {
  dockerfile = "Dockerfile.multistage"
  args = {
    LANG_TYPE = "golang"
  }
  tags = [
    "${DOCKER_REGISTRY}/${IMAGE_NAME}:golang",
  ]
  output = ["type=docker"]
}

target "java" {
  dockerfile = "Dockerfile.multistage"
  args = {
    LANG_TYPE = "java"
  }
  tags = [
    "${DOCKER_REGISTRY}/${IMAGE_NAME}:java",
  ]
  output = ["type=docker"]
}

// Single-stage variants (for comparison)
target "rust-legacy" {
  dockerfile = "Dockerfile.multi"
  args = {
    LANG_TYPE = "rust"
  }
  tags = [
    "${DOCKER_REGISTRY}/${IMAGE_NAME}:rust-legacy",
  ]
  output = ["type=docker"]
}

target "python-legacy" {
  dockerfile = "Dockerfile.multi"
  args = {
    LANG_TYPE = "python"
  }
  tags = [
    "${DOCKER_REGISTRY}/${IMAGE_NAME}:python-legacy",
  ]
  output = ["type=docker"]
}

target "node-legacy" {
  dockerfile = "Dockerfile.multi"
  args = {
    LANG_TYPE = "node"
  }
  tags = [
    "${DOCKER_REGISTRY}/${IMAGE_NAME}:node-legacy",
  ]
  output = ["type=docker"]
}

target "golang-legacy" {
  dockerfile = "Dockerfile.multi"
  args = {
    LANG_TYPE = "golang"
  }
  tags = [
    "${DOCKER_REGISTRY}/${IMAGE_NAME}:golang-legacy",
  ]
  output = ["type=docker"]
}

target "java-legacy" {
  dockerfile = "Dockerfile.multi"
  args = {
    LANG_TYPE = "java"
  }
  tags = [
    "${DOCKER_REGISTRY}/${IMAGE_NAME}:java-legacy",
  ]
  output = ["type=docker"]
}

// Group all targets
group "default" {
  targets = ["base", "rust", "python", "node", "golang", "java"]
}

// Group for language targets only (faster if base is done)
group "languages" {
  targets = ["rust", "python", "node", "golang", "java"]
}

// Legacy single-stage variants (for comparison)
group "legacy" {
  targets = ["rust-legacy", "python-legacy", "node-legacy", "golang-legacy", "java-legacy"]
}
