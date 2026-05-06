#!/bin/bash
set -e

echo "=== Running base.sh ==="

# 更新软件源
apt-get update

# 安装基础工具
apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    iputils-ping \
    ca-certificates \
    software-properties-common \
    unzip \
    zip

# 配置时区
timedatectl set-timezone UTC || true

# 禁用cloud-init网络等待
systemctl disable cloud-init || true

echo "=== base.sh completed ==="