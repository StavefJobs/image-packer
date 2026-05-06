#!/bin/bash
set -e

echo "=== Running cleanup.sh ==="

# 清理apt缓存
apt-get clean
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/apt/archives/*

# 清理日志
rm -rf /var/log/*.log
rm -rf /var/log/syslog*
journalctl --vacuum-time=1s 2>/dev/null || true

# 清理临时文件
rm -rf /tmp/*
rm -rf /var/tmp/*

# 清理旧内核（保留当前内核）
dpkg -l 'linux-*' 2>/dev/null | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]*\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | head -n -1 | xargs apt-get -y purge 2>/dev/null || true

# 清空硬盘空闲空间（减小镜像大小）
dd if=/dev/zero of=/EMPTY bs=1M 2>/dev/null || true
rm -f /EMPTY
sync

# 重置machine-id（为cloud-init准备）
echo '' > /etc/machine-id

# 清理cloud-init缓存
cloud-init clean --logs --seed || true

# 清理历史记录
rm -f /home/vagrant/.bash_history
history -c

# 清理SSH host keys（重新生成）
rm -f /etc/ssh/ssh_host_*

echo "=== cleanup.sh completed ==="