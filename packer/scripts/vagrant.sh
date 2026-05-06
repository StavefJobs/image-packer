#!/bin/bash
set -e

echo "=== Running vagrant.sh ==="

# 创建vagrant用户SSH目录
mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh

# 下载vagrant公钥
curl -fsSL https://raw.githubusercontent.com/mitchell/vagrant/master/keys/vagrant.pub > /home/vagrant/.ssh/authorized_keys

# 设置正确的权限
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# 启用SSH密码认证
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 允许Root登录（用于Vagrant）
sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# 重启SSH服务
systemctl restart ssh

# 配置sudo无密码（vagrant用户）
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant

# 安装qemu-guest-agent（可选，用于Vagrant检测IP）
apt-get install -y qemu-guest-agent 2>/dev/null || true

echo "=== vagrant.sh completed ==="