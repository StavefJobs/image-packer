#!/bin/bash
set -e

echo "=== Running node.sh ==="

# 安装nvm v0.40.4
export NVM_DIR="/home/vagrant/.nvm"

# 下载并安装nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# 加载nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 安装Node.js 24
nvm install 24
nvm use 24
nvm alias default 24

# 验证安装
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

# 配置npm
npm config set prefix '~/.npm-global'
mkdir -p ~/.npm-global

# 添加到.bashrc使nvm持久化
if ! grep -q "NVM_DIR" /home/vagrant/.bashrc; then
    cat >> /home/vagrant/.bashrc << 'EOF'

# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
fi

echo "=== node.sh completed ==="