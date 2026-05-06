#!/bin/bash
set -e

echo "=== Running docker.sh ==="

# 添加Docker官方GPG密钥
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# 添加Docker仓库
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装Docker
apt-get update
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# 启动Docker服务
systemctl enable docker
systemctl start docker

# 将vagrant用户添加到docker组
usermod -aG docker vagrant

# 验证Docker安装
docker --version
docker compose version

echo "=== docker.sh completed ==="