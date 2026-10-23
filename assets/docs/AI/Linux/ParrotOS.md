## 1. Parrot-OS 下载与配置
* [Parrot-OS官网](https://parrotsec.org/)

### 哈希值检查
<details>
<summary>如何检查哈希值（点击展开）</summary>

```bash
# 此处以 Parrot-security-7.1_amd64.iso 为例
# 进入ISO文件所在目录
cd /path/to/iso/
# 计算MD5哈希
md5sum Parrot-security-7.1_amd64.iso
# 计算SHA256哈希
sha256sum Parrot-security-7.1_amd64.iso
# 计算SHA512哈希
sha512sum Parrot-security-7.1_amd64.iso
# 自行对比
```

</details>

<details>
<summary>校验拓展</summary>

```bash
# 批量生成校验
md5sum *.7z *.rar > MD5SUMS
sha256sum *.7z *.rar > SHA256SUMS
sha512sum *.7z *.rar > SHA512SUMS
# 批量对比校验
md5sum -c MD5SUMS
sha256sum -c SHA256SUMS
sha512sum -c SHA512SUMS
# 单个对比校验
grep -F "clover-days-r18-patch.zip" SHA256SUMS | sha256sum -c
# 追加生成校验
md5sum *.zip >> MD5SUMS
sha256sum *.zip >> SHA256SUMS
sha512sum *.zip >> SHA512SUMS
```

</details>

### 安装系统
<details>
<summary>1. 安装系统(Linux)</summary>

* 1. 首先需要一个 U 盘,进行烧录系统
* [balena官网下载](https://github.com/balena-io/etcher/releases)
```bash
# 1. 烧录 U 盘
# 选择.deb下载
# 以 balena-etcher_2.1.4_amd64.deb 为例
# 自行加sudo
dpkg -i balena-etcher_2.1.4_amd64.deb 
# 运行图形化
balena-etcher 
# 1.1 点击 Flash from file
# 选择ISO文件(镜像)
# Parrot-security-7.0_amd64.iso
# 1.2 Select target 选择U盘进行烧录
# 1.3 Flash! 选择U盘进行烧录
```
* 2. 重启 , 进入BIOS选择 USB 启动 (一般按F2,如不是,上官网查询)
* 3. 启动后按照提示安装即可

</details>
<details>
<summary>2. 安装系统(windows)</summary>

* 1. 首先需要一个 U 盘,进行烧录系统
* [balena官网下载](https://github.com/balena-io/etcher/releases)
    * 1.1 点击 Flash from file
    * 选择ISO文件(镜像)
    * Parrot-security-7.0_amd64.iso
    * 1.2 Select target 选择U盘进行烧录
    * 1.3 Flash! 选择U盘进行烧录

* 2. 重启 , 进入BIOS选择 USB 启动 (一般按F2,如不是,上官网查询)
* 3. 启动后按照提示安装即可

</details>

* 安装其他系统同理

### 个性化设置
```bash
# 1. 桌面背景
# 左上角点击   系统  -> 首选项 -> 外观  -->  外观  --->   背景
# 2. 锁屏背景
# 左上角点击   系统  -> 首选项 -> 外观  -->  屏幕保护程序  --->   锁屏背景图
# 自定义锁屏背景需要在 放在 锁屏背景路径下
sudo -i
# 锁屏背景路径
cd /usr/share/images/desktop-base/
cp path/bg.jpg  .
```

### 系统更新

<details>
<summary>系统更新</summary>

```bash
parrot-upgrade
# parrot-updater
```

</details>

## 2. Parrot-OS 显卡驱动安装

### 1. 前期准备
```bash
# 1.1. 检查显卡型号
lspci | grep -i vga
# 针对 NVIDIA/AMD 专用
lspci | grep -i nvidia
lspci | grep -i amd
# 1.2. 检查当前驱动
# 如果输出为空，说明使用默认开源驱动。
lsmod | grep -i nvidia  # NVIDIA
lsmod | grep -i amdgpu # AMD
```

```bash
# 1.3. 更新系统
sudo apt update
# 1.4. 通用依赖
# build-essential：编译工具。
# dkms：动态内核模块支持，确保驱动在内核更新后存活。
# linux-headers：匹配当前内核。
# firmware-misc-nonfree：非自由固件。
sudo apt install build-essential dkms linux-headers-$(uname -r) firmware-misc-nonfree
```

<details>
<summary>避坑指南</summary>

* 避坑提示：如果使用 Secure Boot（UEFI），需禁用或签名驱动模块。运行 mokutil --sb-state 检查 Secure Boot 状态。如果启用，安装时会提示错误，需进入 BIOS 禁用。
* 测试：在 Live USB 模式下运行 Parrot OS，测试驱动兼容性。
常见新手坑：
* 坑1：直接从 NVIDIA/AMD 官网下载 .run 文件安装。这会覆盖系统文件，导致无法恢复。解决方案：优先使用仓库安装。
* 坑2：忽略 Xorg 配置。安装后图形界面黑屏，通常因 Xorg 未识别驱动。
* 坑3：混合使用开源和专有驱动。解决方案：卸载开源驱动：sudo apt remove xserver-xorg-video-nouveau (NVIDIA) 或 sudo apt remove xserver-xorg-video-amdgpu (AMD)。

</details>

### 2. NVIDIA 显卡驱动安装实战操作
```bash
# 2.1 安装驱动
# 步骤1：卸载旧驱动（如果有）：
sudo apt purge nvidia* libnvidia*  # 清除所有 NVIDIA 相关
sudo apt autoremove
# 步骤2：安装推荐驱动
sudo apt install nvidia-driver
# 或指定版本（如 535）：
# sudo apt install nvidia-driver-535
# 步骤3：禁用开源驱动
sudo nano /etc/modprobe.d/blacklist-nouveau.conf
```
```
blacklist nouveau
options nouveau modeset=0
alias nouveau off
```
```bash
sudo update-initramfs -u
# 步骤4：重启并验证：
# sudo reboot
# 重启后，运行
nvidia-smi  # 显示 GPU 状态、温度、驱动版本
```

<details>
<summary>示例输出</summary>

nvidia-smi
```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 535.129.03   Driver Version: 535.129.03   CUDA Version: 12.2     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  Off  | 00000000:01:00.0 Off |                  N/A |
| N/A   45C    P8    N/A /  N/A |    100MiB /  4096MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
```

</details>
<details>
<summary>常见问题解决</summary>

```bash
# grub
sudo nano /etc/default/grub
# GRUB_CMDLINE_LINUX_DEFAULT='quiet splash nvidia-drm.modeset=1 nouveau.modeset=0'
sudo update-grub
```

```bash
# Error! Bad return status for module build on kernel: 6.19.6+parrot7-amd64 (x86_64)
# 查看内核(ParrotOS7.1更新后双内核问题)
uname -r
ls /lib/modules
# ls /lib/modules/6.19.6+parrot7-amd64
# 1. 删除 6.19 内核模块目录
sudo rm -rf /lib/modules/6.19.6+parrot7-amd64
sudo apt remove --purge linux-image-6.19.6+parrot7-amd64 linux-image-amd64
sudo apt autoremove
# 2. 清理 DKMS 中所有 NVIDIA 相关记录
sudo dkms remove nvidia-current/550.163.01 --all
sudo rm -rf /var/lib/dkms/nvidia-current
sudo rm -rf /usr/src/nvidia-*
# 3. 重新安装当前内核头文件（确保完整）
sudo apt install --reinstall linux-headers-$(uname -r)
# 4. 彻底清除 NVIDIA 包并重装
sudo apt purge nvidia-* bumblebee-*
sudo apt autoremove --purge
sudo apt update
sudo apt install nvidia-driver
# 安装大黄蜂(双显卡)
sudo apt install bumblebee-nvidia primus-nvidia primus-vk-nvidia nvidia-smi -y
# sudo apt install nvidia-cuda-dev nvidia-cuda-toolkit
sudo nano /etc/bumblebee/bumblebee.conf
```
```bash
# 大黄蜂N卡设置
# 1
# (See also the driver-specific sections below)
Driver=nvidia # 此处修改
# 2
[driver-nvidia]
# Module name to load, defaults to Driver if empty or unset
KernelDriver=nvidia-current # 此处修改
```
```bash
# 问题2：DKMS 编译失败（内核不匹配）。
# 解决：确保 headers 安装正确：sudo apt install linux-headers-$(uname -r)。然后：
sudo dkms autoinstall
# 问题3：多显示器或分辨率问题。
# 使用 nvidia-settings GUI 工具调整：
# nvidia-settings
# 或编辑 /etc/X11/xorg.conf 添加 Monitor 部分。
# 性能优化：启用 Coolbits 以超频（风险高）： 在 xorg.conf 的 Device 部分添加：
# Option "Coolbits" "8"
# 重启后用 nvidia-settings 调整。
```

</details>

### 2.1. steam安装
```bash
# 更新软件源
sudo apt update
sudo apt upgrade
# 添加Flathub仓库
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# 安装Steam
flatpak install flathub com.valvesoftware.Steam
# 启动steam
flatpak run com.valvesoftware.Steam
```

<details>
<summary>下载steam缓慢?</summary>

添加镜像Flathub仓库
```bash
sudo flatpak remote-modify flathub --url=国内镜像
```

</details>

<details>
<summary>其他</summary>

办公office
```bash
sudo flatpak install flathub org.onlyoffice.desktopeditors
```
修复vlc打不开
```bash
vlc --reset-config
vlc --reset-plugins-cache
```

</details>
