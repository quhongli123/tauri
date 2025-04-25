#!/bin/bash
set -e  # 遇到错误立即退出

# 清理旧的构建容器和镜像
echo "清理旧的容器和镜像..."
docker rm -f tauri-builder 2>/dev/null || true
docker rmi -f tauri-linux-arm64-builder 2>/dev/null || true

# 构建 Docker 容器
echo "开始构建 Docker 镜像..."
docker build -t tauri-linux-arm64-builder .

# 运行容器并构建应用
echo "在容器中运行构建过程..."
docker run --name tauri-builder -it tauri-linux-arm64-builder || {
    echo "构建失败，正在导出日志..."
    docker logs tauri-builder > build-error.log
    echo "错误日志已保存到 build-error.log 文件"
    exit 1
}

# 创建输出目录
mkdir -p ./dist-linux-arm64

# 从容器中复制构建产物
echo "从容器中复制构建产物..."
docker cp tauri-builder:/app/src-tauri/target/aarch64-unknown-linux-gnu/release/bundle ./dist-linux-arm64 || {
    echo "无法复制构建产物，检查容器中的文件..."
    docker exec tauri-builder ls -la /app/src-tauri/target/ || true
    docker exec tauri-builder find /app/src-tauri/target/ -name "*.deb" -o -name "*.AppImage" || true
    exit 1
}

# 显示构建结果
echo "构建结果目录内容:"
ls -la ./dist-linux-arm64/bundle 2>/dev/null || echo "构建结果目录为空!"

# 删除容器
echo "清理容器..."
docker rm -f tauri-builder

echo "完成！如果构建成功，Linux arm64 包已生成在 ./dist-linux-arm64/bundle 目录下" 