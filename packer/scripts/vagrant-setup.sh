#!/bin/bash
set -e

# 创建vagrant用户
useradd -m -s /bin/bash vagrant

# 设置密码
echo 'vagrant:vagrant' | chpasswd

# 配置sudo无密码
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vagrant

# 配置SSH密钥
mkdir -p /home/vagrant/.ssh
cat > /home/vagrant/.ssh/authorized_keys <<'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0fHiJrGhtEF8l3V5DehZIBazrK8f6WWXPiAywT5nTjDMI1QMArS1e1AkbQX5EdSruW5YhYV5qH2vVOVriZ2FbcCth2HkE3WdZRjQlVoheLzLwhV4AoP6R60HVSF0Yd8y6DHpizg7QlvWyKHtjB9zZ1a7kGwWG28MJ5TFCc6GAtGXRSqKFGb9y3SJN+LEVZNQAiNSlpVwP0HSpVYQ0oB2S2HzVRF6lBsfAYV4ihYgYODkvQcIj8cZCWJY8B0Cr5PbZ5FQfT2gb5Z70ZuFkGEnJ5xI5l5UwXgTgjI1CcB0yxsPVLWEvnM1y3K6c8qDnVfYqy5n2J7 vagrant insecure public key
EOF
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# 安装必要软件
apt-get update
apt-get install -y openssh-server cloud-init vim sudo curl gnupg lsb-release

# 安装Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 安装Python 3.14 (通过deadsnakes PPA for Ubuntu或默认版本for Debian)
if [ -f /etc/debian_version ]; then
  if grep -q "Ubuntu" /etc/os-release; then
    apt-get install -y software-properties-common
    add-apt-repository ppa:deadsnakes/ppa -y || true
    apt-get update
    apt-get install -y python3.14 || apt-get install -y python3
  else
    apt-get update
    apt-get install -y python3 || true
  fi
fi

# 启用SSH
systemctl enable ssh
