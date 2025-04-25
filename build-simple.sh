#!/bin/bash
###
 # @Author: 曲洪利 quhongli999@163.com
 # @Date: 2025-04-25 09:48:31
 # @LastEditors: 曲洪利 quhongli999@163.com
 # @LastEditTime: 2025-04-25 10:33:15
 # @FilePath: /tauri-app/build-simple.sh
 # @Description: 
 # 
 # Copyright (c) 2025 by ${git_name_email}, All Rights Reserved. 
### 
set -e  # 遇到错误立即退出

# 清理旧的容器和镜像
echo "清理旧的容器和镜像..."
docker rm -f tauri-builder-simple 2>/dev/null || true
docker rmi -f tauri-builder-simple 2>/dev/null || true

# 构建 Docker 镜像
echo "开始构建 Docker 镜像..."
docker build -t tauri-builder-simple -f Dockerfile.simple .

# 运行容器并构建应用
echo "在容器中运行构建过程..."
docker run --name tauri-builder-simple tauri-builder-simple || {
    echo "构建失败，正在导出日志..."
    docker logs tauri-builder-simple > build-error.log
    echo "错误日志已保存到 build-error.log 文件"
    exit 1
}

# 创建输出目录
mkdir -p ./dist-linux

# 从容器中复制构建产物
echo "从容器中复制构建产物..."
docker cp tauri-builder-simple:/app/src-tauri/target/release/bundle ./dist-linux || {
    echo "无法复制构建产物，检查容器中的文件..."
    docker exec tauri-builder-simple ls -la /app/src-tauri/target/ || true
    docker exec tauri-builder-simple find /app/src-tauri/target/ -name "*.deb" -o -name "*.AppImage" || true
    exit 1
}

# 显示构建结果
echo "构建结果目录内容:"
ls -la ./dist-linux/bundle 2>/dev/null || echo "构建结果目录为空!"

# 删除容器
echo "清理容器..."
docker rm -f tauri-builder-simple

echo "完成！如果构建成功，Linux 包已生成在 ./dist-linux/bundle 目录下" 