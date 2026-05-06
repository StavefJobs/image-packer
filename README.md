# Image Packer - Vagrant Box自动化构建

基于cloud镜像自动构建Vagrant box的GitHub Actions工作流。

## 支持的操作系统和Provider

| 操作系统 | 版本 | Provider支持 |
|---------|------|--------------|
| Debian | 12 (Bookworm) | libvirt, virtualbox, vmware |
| Debian | 13 (Trixie) | libvirt, virtualbox, vmware |
| Ubuntu | 24.04 LTS (Noble) | libvirt, virtualbox, vmware |
| Ubuntu | 26.04 LTS | libvirt, virtualbox, vmware |

## 预装软件

- Docker CE
- Python 3.14 (或系统默认Python 3)
- Node.js 24 (通过nvm v0.40.4安装)
- OpenSSH Server
- cloud-init
- vim, sudo等基础工具

## 默认配置

- 磁盘大小：40GB
- 内存：1024MB
- CPU：1核
- SSH用户：vagrant / vagrant
- SSH密钥：使用Vagrant默认insecure public key

## 使用方法

### 自动构建（推荐）

推送tag触发自动构建：

```bash
git tag v1.0.0
git push origin v1.0.0
```

构建完成后，box文件将自动上传到GitHub Releases。

### 手动触发

在GitHub仓库的Actions页面，选择"Build Vagrant Boxes"工作流，点击"Run workflow"，可以选择：

- OS版本：all / debian12 / debian13 / ubuntu2404 / ubuntu2604
- Provider：all / libvirt / virtualbox / vmware

### 使用构建的Box

```bash
# 下载box文件后
vagrant box add debian12-libvirt.box --name debian12 --provider libvirt

# 在Vagrantfile中使用
Vagrant.configure("2") do |config|
  config.vm.box = "debian12"
  config.vm.provider "libvirt" do |lv|
    lv.memory = 2048
    lv.cpus = 2
  end
end
```

## 构建流程

1. 下载官方cloud镜像（qcow2格式）
2. 调整磁盘大小至40GB
3. 使用virt-customize注入vagrant配置
4. 安装Docker CE和Python 3.14
5. 根据provider转换镜像格式：
   - libvirt: 直接使用qcow2
   - virtualbox: 转换为vmdk + 生成ovf
   - vmware: 转换为vmdk + 生成vmx
6. 打包为.box文件
7. 上传到GitHub Releases（仅tag触发）

## 注意事项

- Ubuntu 26.04已发布，支持libvirt/virtualbox/vmware三种provider
- 构建过程完全在GitHub Actions中完成，无需自托管runner
- 由于GitHub Actions限制，无法在构建过程中测试box（无嵌套虚拟化）
- 建议在发布前本地测试构建的box文件

## 许可证

MIT License
