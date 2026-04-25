# dind - Docker in Docker with Multiple Programming Languages

这是一个扩展的 dind 镜像，包含了多个编程语言的版本。所有镜像都使用阿里云 Ubuntu 镜像源以加快下载速度。

## 可用的镜像标签

- `dind` - 基础镜像（包括 Docker、Python3）
- `dind:rust` - Rust 开发环境
- `dind:python` - Python 开发环境（包括 pip）
- `dind:node` - Node.js 开发环境（包括 npm）
- `dind:golang` - Go 开发环境
- `dind:java` - Java 开发环境（包括 Maven）

## 特性

- 所有镜像都包含完整的 Docker 工具
- 使用阿里云 Ubuntu 镜像源加快安装速度
- 包含 Docker Compose
- 配置了 SSH 服务
- 每个镜像都包含该编程语言的官方最新版本
- **高效的构建方案**：使用单个 Dockerfile.multi 和 --build-arg 参数，通过条件安装来构建所有镜像变体

## 快速开始

### 方案一：使用 Buildx Bake 多阶段构建（推荐 - 最快）⚡

Buildx Bake 结合多阶段构建，使用分层缓存和真正的并行构建，速度最快，镜像最小。

```bash
chmod +x build-bake.sh
./build-bake.sh
```

或直接使用 buildx 命令：

```bash
# 构建所有镜像（多阶段优化）
docker buildx bake --progress=plain --secret id=my_secret_var,src=arg.txt

# 只构建语言镜像（跳过基础镜像）
docker buildx bake languages --progress=plain --secret id=my_secret_var,src=arg.txt

# 构建遗留版本（单阶段）用于对比
docker buildx bake legacy --progress=plain --secret id=my_secret_var,src=arg.txt
```

**优点：**
- ✅ 多阶段构建 - 镜像尺寸优化
- ✅ 真正的并行构建多个镜像
- ✅ 智能层级缓存，重复构建更快
- ✅ 支持多平台交叉编译
- ✅ 构建进度清晰可见

### 方案二：使用并行脚本（无需 Buildx）

如果没有安装 Buildx，使用以下脚本进行并行构建：

```bash
chmod +x build-all.sh
./build-all.sh
```

此脚本使用 `Dockerfile.multi`（单阶段版本）

**优点：**
- ✅ 5 个语言镜像同时并行构建
- ✅ 无需额外工具依赖
- ✅ 速度快

### 构建单个镜像

#### 使用 Buildx Bake 多阶段构建：

```bash
# 构建单个语言镜像（多阶段优化）
docker buildx bake rust --progress=plain --secret id=my_secret_var,src=arg.txt
docker buildx bake python --progress=plain --secret id=my_secret_var,src=arg.txt
docker buildx bake node --progress=plain --secret id=my_secret_var,src=arg.txt
docker buildx bake golang --progress=plain --secret id=my_secret_var,src=arg.txt
docker buildx bake java --progress=plain --secret id=my_secret_var,src=arg.txt

# 或只构建语言镜像组（跳过基础镜像）
docker buildx bake languages --progress=plain --secret id=my_secret_var,src=arg.txt

# 查看可用的构建目标
docker buildx bake --print
```

#### 使用传统 Docker Build（多阶段）：

```bash
# 使用 Dockerfile.multistage 构建（多阶段优化）
docker build --secret id=my_secret_var,src=arg.txt --build-arg LANG_TYPE=rust -f Dockerfile.multistage -t dind:rust .
docker build --secret id=my_secret_var,src=arg.txt --build-arg LANG_TYPE=python -f Dockerfile.multistage -t dind:python .
# 其他语言类似...
```

#### 使用单阶段 Docker Build（仅用于对比）：

```bash
# 使用 Dockerfile.multi 构建（单阶段版本，用于与多阶段对比）
docker build --secret id=my_secret_var,src=arg.txt --build-arg LANG_TYPE=rust -f Dockerfile.multi -t dind:rust-legacy .

### 运行镜像

```bash
# 运行基础 dind 镜像
docker run -d --privileged --name dind dind

# 运行 Rust 版本
docker run -d --privileged --name dind-rust dind:rust

# 运行 Python 版本
docker run -d --privileged --name dind-python dind:python

# 运行 Node.js 版本
docker run -d --privileged --name dind-node dind:node

# 运行 Go 版本
docker run -d --privileged --name dind-golang dind:golang

# 运行 Java 版本
docker run -d --privileged --name dind-java dind:java
```

### 进入容器

```bash
docker exec -it dind-rust bash
docker exec -it dind-python bash
docker exec -it dind-node bash
docker exec -it dind-golang bash
docker exec -it dind-java bash
```

### 验证安装的编程语言

```bash
# 验证 Rust
docker exec dind-rust rustc --version

# 验证 Python
docker exec dind-python python3 --version

# 验证 Node.js
docker exec dind-node node --version

# 验证 Go
docker exec dind-golang go version

# 验证 Java
docker exec dind-java java -version
```

## 镜像构建方案

### 推荐方案 - 多阶段构建 (Multi-Stage Builds) ⭐

所有编程语言镜像都使用 `Dockerfile.multistage` 的多阶段构建技术：

```dockerfile
# Stage 1: Builder - 编译工具和依赖
FROM ubuntu as builder
RUN install build tools...

# Stage 2: Runtime - 最终镜像
FROM ubuntu
COPY --from=builder /artifacts /app
```

使用多阶段构建的优点：
- ✅ **镜像更小** - 编译工具不包含在最终镜像中
- ✅ **缓存更高效** - 每个阶段独立缓存
- ✅ **构建更快** - Docker 可以并行处理多个阶段
- ✅ **安全更好** - 最终镜像只包含需要的运行时环境

### 传统单阶段方案 (遗留版本)

`Dockerfile.multi` 提供了向后兼容的单阶段构建版本。

对比：

| 特性 | 多阶段 | 单阶段 |
|------|-------|-------|
| 镜像大小 | 较小 | 较大 |
| 构建速度 | 较快 | 较慢 |
| 层级缓存 | 优化 | 标准 |
| 网络依赖 | 最小化 | 完整 |

## 系统要求

- Docker 版本需要支持 `docker build --secret` 功能（Docker 18.09+）
- `arg.txt` 文件应包含 SSH root 用户密码

## 镜像优化和大小对比

### 多阶段构建的优化

已创建的 Dockerfile 文件使用以下优化技术：

| 优化技术 | 文件 | 说明 |
|--------|------|------|
| 多阶段构建 | `Dockerfile.multistage` | 分离编译环境和运行环境 |
| 条件安装 | ARG + RUN if | 只安装选定的语言工具 |
| 阿里云镜像源 | sed 替换 | 加快国内网络的安装速度 |
| Buildx Bake | `docker-bake.hcl` | 并行构建和缓存优化 |

### 检查镜像大小

```bash
# 查看所有 dind 镜像大小
docker images dind

# 检查具体镜像的详细大小（需要 numfmt 工具）
docker inspect dind:python --format='{{.Size}}' | numfmt --to=iec

# 对比多阶段和单阶段的大小
docker inspect dind:rust --format='{{.Size}}'      # 多阶段
docker inspect dind:rust-legacy --format='{{.Size}}'  # 单阶段

# 显示所有 dind 镜像及其大小
docker images | grep "dind"
```

### 推荐的文件使用

| 需求 | 使用文件 | 构建命令 |
|------|--------|--------|
| 最佳性能 | `Dockerfile.multistage` + `Buildx Bake` | `./build-bake.sh` |
| 快速兼容 | `Dockerfile.multi` + Buildx 并行 | `docker buildx bake --progress=plain` |
| 无依赖环境 | `Dockerfile.multi` + Shell 脚本 | `./build-all.sh` |
| 传统方式 | `Dockerfile.multi` | `docker build -f Dockerfile.multi` |

### 使用 Buildx 的额外要求

对于最快的 Buildx 构建方式，需要：

- Docker 版本 20.10+
- Docker Buildx 插件（通常预装在 Docker Desktop 中）

如果没有 Buildx，可以安装：

```bash
# macOS/Windows (Docker Desktop) - 通常已预装
# Linux - 需要手动安装
docker buildx version  # 检查是否已安装

# 如果需要安装（Linux）
mkdir -p ~/.docker/cli-plugins
wget https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-amd64 -O ~/.docker/cli-plugins/docker-buildx
chmod +x ~/.docker/cli-plugins/docker-buildx
```

## 许可证

该项目基于 jpetazzo/dind 项目，查看 LICENSE 文件了解详情。
