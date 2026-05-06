packer {
  required_version = ">= 1.7.0"

  required_plugins {
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "version" {
  type    = string
  default = "1.0.0"
  description = "Version number for the box"
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/noble/ubuntu-24.04.3-live-server-amd64.iso"
  description = "URL to the Ubuntu ISO"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:8762f7e74e4d64d72fceb5f70682e6b069932deedb4949c6975d0f0fe0a91be3"
  description = "SHA256 checksum of the ISO"
}

variable "disk_size" {
  type    = number
  default = 40960
  description = "Disk size in MB (40GB)"
}

variable "memory" {
  type    = number
  default = 4096
  description = "RAM in MB"
}

variable "cpus" {
  type    = number
  default = 2
  description = "Number of CPUs"
}

source "virtualbox-iso" "ubuntu2404" {
  vm_name              = "ubuntu2404-${var.version}"
  guest_os_type        = "Ubuntu_64"
  iso_url             = var.iso_url
  iso_checksum        = var.iso_checksum

  http_directory      = "http"
  boot_command        = ["e<wait><down><down><down><end> autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/<enter>"]
  boot_wait           = "5s"

  ssh_username        = "vagrant"
  ssh_password        = "vagrant"
  ssh_timeout         = "30m"

  shutdown_command    = "echo 'vagrant' | sudo -S shutdown -P now"

  disk_size          = var.disk_size
  memory             = var.memory
  cpus               = var.cpus

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
    ["modifyvm", "{{.Name}}", "--vram", "128"],
    ["modifyvm", "{{.Name}}", "--clipboard", "bidirectional"],
    ["modifyvm", "{{.Name}}", "--draganddrop", "bidirectional"]
  ]

  headless           = true
  firmware           = "efi"
}

build {
  sources = ["source.virtualbox-iso.ubuntu2404"]

  # 等待cloud-init完成
  provisioner "shell" {
    execute_command = "echo 'vagrant' | sudo -S bash -c '{{ .Path }}'"
    inline = [
      "cloud-init status --wait",
      "echo 'Cloud-init completed'"
    ]
    timeout = "15m"
  }

  # 安装基础软件
  provisioner "shell" {
    execute_command = "echo 'vagrant' | sudo -S bash -c '{{ .Path }}'"
    script = "scripts/base.sh"
    timeout = "30m"
  }

  # 安装Docker
  provisioner "shell" {
    execute_command = "echo 'vagrant' | sudo -S bash -c '{{ .Path }}'"
    script = "scripts/docker.sh"
    timeout = "30m"
  }

  # 安装nvm和Node 24
  provisioner "shell" {
    execute_command = "echo 'vagrant' | sudo -S bash -c '{{ .Path }}'"
    script = "scripts/node.sh"
    timeout = "30m"
  }

  # 配置Vagrant用户
  provisioner "shell" {
    execute_command = "echo 'vagrant' | sudo -S bash -c '{{ .Path }}'"
    script = "scripts/vagrant.sh"
    timeout = "10m"
  }

  # 清理和优化
  provisioner "shell" {
    execute_command = "echo 'vagrant' | sudo -S bash -c '{{ .Path }}'"
    script = "scripts/cleanup.sh"
    timeout = "15m"
  }

  # 生成Vagrant box
  post-processor "vagrant" {
    output      = "output/ubuntu2404-${var.version}.box"
    vagrantfile = "template/Vagrantfile"
  }
}