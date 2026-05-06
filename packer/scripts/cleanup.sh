#!/bin/bash
set -e

# 清理APT缓存
apt-get clean
apt-get autoclean

# 清理临时文件
rm -rf /tmp/*
rm -rf /var/tmp/*

# 清理日志
find /var/log -type f -exec truncate -s 0 {} \;

# 清理SSH host keys
rm -f /etc/ssh/ssh_host_*

# 清理cloud-init
cloud-init clean --logs --seed

# 清理历史记录
rm -f /home/vagrant/.bash_history
rm -f /root/.bash_history

# 清理包管理器缓存
rm -rf /var/lib/apt/lists/*
