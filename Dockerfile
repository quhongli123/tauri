FROM ubuntu:22.04

# 避免交互式配置
ARG DEBIAN_FRONTEND=noninteractive

# 安装基本工具和依赖
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    libwebkit2gtk-4.0-dev \
    libgtk-3-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    wget \
    git \
    unzip \
    nodejs \
    npm \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    libc6-arm64-cross \
    libc6-dev-arm64-cross \
    libgcc-s1-arm64-cross \
    libstdc++-12-dev-arm64-cross \
    gdb-multiarch \
    qemu-user \
    && rm -rf /var/lib/apt/lists/*

# 配置交叉编译环境
ENV PKG_CONFIG_ALLOW_CROSS=1
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc
ENV CC_aarch64_unknown_linux_gnu=aarch64-linux-gnu-gcc
ENV CXX_aarch64_unknown_linux_gnu=aarch64-linux-gnu-g++
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_RUNNER="qemu-aarch64 -L /usr/aarch64-linux-gnu"

# 安装 Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 添加 arm64 目标
RUN rustup target add aarch64-unknown-linux-gnu

# 创建配置文件目录
RUN mkdir -p /root/.cargo
RUN echo '[target.aarch64-unknown-linux-gnu]' > /root/.cargo/config.toml
RUN echo 'linker = "aarch64-linux-gnu-gcc"' >> /root/.cargo/config.toml

# 安装 pnpm
RUN npm install -g pnpm

# 设置工作目录
WORKDIR /app

# 将源代码复制到容器中
COPY . .

# 构建应用程序（增加调试输出）
CMD ["sh", "-c", "echo '开始构建...' && pnpm install && pnpm build && cd src-tauri && ls -la && cargo tauri build --target aarch64-unknown-linux-gnu --verbose"] 