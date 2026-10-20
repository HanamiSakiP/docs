<div align="center">
  <h1 align="center">
    <a href="/luJTwX54bBjJ7R1f5lkd7gQ" title="关注塔菲喵">
      <img src="assets/docs/images/M.jpg" width="200" alt="">
    </a>
    <br/>
    CrazyThursdayVivo50
  </h1>
</div>

## 简介

* start
```bash
mkdir -p ~/.local/share/devmgr/backups
cd ~/.local/share/devmgr
git clone https://github.com/HanamiSakiP/AI.git
```
```bash
cp -r ~/.local/share/devmgr/AI/dev/backups ~/.local/share/devmgr/
mkdir -p ~/.local/bin
install -m755 ~/.local/share/devmgr/AI/dev/dev ~/.local/bin
install -m755 ~/.local/share/devmgr/AI/dev/undev ~/.local/bin
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
ls ~/.local/bin
dev restore # install
source ~/.bashrc
ls ~/.local/share/devmgr/backups
```

<details>
<summary>test</summary>

docker
```bash
# 最新版debian
docker pull debian # podman同理
# 精简版debian
docker pull debian:trixie-slim # podman同理
```
docker
```bash
docker run -d --name test-debian debian:latest sleep infinity
docker exec -it test-debian mkdir -p /root/.local/share/devmgr/AI
docker cp ~/.local/share/devmgr/backups/AI test-debian:/root/.local/share/devmgr/AI
docker exec -it test-debian /bin/bash
# 强制删除容器
# docker rm -f test-debian
```
podman
```bash
podman run -d --name test-debian debian:latest sleep infinity
podman exec -it test-debian mkdir -p /root/.local/share/devmgr/devmgr/AI
podman cp ~/.local/share/devmgr/backups/AI test-debian:/root/.local/share/devmgr/AI
podman exec -it test-debian /bin/bash
# 强制删除容器
# podman rm -f test-debian
```
apt
```bash
apt update
apt install curl git -y # nano
```
```bash
# pyenv依赖
apt install -y build-essential \
libssl-dev \
zlib1g-dev \
libbz2-dev \
libreadline-dev \
libsqlite3-dev \
libffi-dev \
liblzma-dev \
pkg-config
```


</details>

<details>
<summary>tools</summary>

```bash
docsify serve .
# 每天02点执行rclone同步
0 2 * * * flock -n /tmp/rclone.lock ~/go/bin/rclone sync /本地/路径 remote:云端路径 --log-file /home/你的用户名/rclone-sync.log --log-level INFO
# 安装tui工具
gh release download --repo denisidoro/navi --pattern "*x86_64-unknown-linux-musl*"
gh release download --repo sxyazi/yazi --pattern "*x86_64-unknown-linux-musl*"
gh release download --repo zellij-org/zellij --pattern "*x86_64-unknown-linux-musl*"
```
cli
```bash
npm i -g nrm
npm i docsify-cli -g
npm install -g @earendil-works/pi-coding-agent
npm install --global rea-agents
npm install -g @opencode/cli
npm install -g @openai/codex
npm install -g @anthropic-ai/claude-code
# go
go install github.com/restic/restic/cmd/restic@latest
go install github.com/rclone/rclone@latest
go install github.com/junegunn/fzf@latest
go install github.com/micro-editor/micro/v2@latest
# go-ai
go install github.com/hybridgroup/yzma@latest
go install github.com/charmbracelet/crush@latest
go install github.com/gpustack/gguf-parser-go/cmd/gguf-parser@latest
# go-docker
go install github.com/google/go-containerregistry/cmd/crane@latest
go install github.com/regclient/regclient/cmd/regctl@latest
# GitHub
go install github.com/cli/cli/v2/cmd/gh@latest
# GitLab
go install gitlab.com/gitlab-org/cli/cmd/glab@latest
# python
pip install httpie
pip install cli-anything-hub
npx skills add HKUDS/CLI-Anything --skill cli-hub-meta-skill -g -y
```

</details>

<details>
<summary>镜像源切换</summary>

```bash
# go临时
export GOPROXY=https://goproxy.cn,direct
# 查看当前go源
go env | grep GOPROXY
# npm源切换工具
npm i -g nrm
# 2、查看可选镜像源
nrm ls
# 3、切换 huawei 镜像源
nrm use huawei
# npm临时示例
# npm install docsify-cli -g --registry=https://registry.npmmirror.com
# 查看当前npm源
npm config get registry
# python临时示例
# pip install httpie -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
# 查看当前pip源
pip config list
# 全局配置git
git config --global url."https://ghproxy.com/https://github.com/".insteadOf "https://github.com/"
# 正常使用
git clone https://github.com/HanamiSakiP/AI.git
# 取消这个镜像
git config --global --unset url."https://ghproxy.com/https://github.com/"
# 临时使用
# git clone https://ghproxy.com/https://github.com/HanamiSakiP/AI.git
# 查看当前git源
git config --global -l | grep insteadOf
```
debian-apt
```bash
cat > fix_source.sh <<'S'
#!/bin/bash
set -e
rm -f /etc/apt/sources.list.d/*.bak.*
CODENAME=$(awk -F'=' '/^VERSION_CODENAME=/{gsub(/"/,"");print $2}' /etc/os-release)

if [ -f "/etc/apt/sources.list.d/debian.sources" ];then
cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.old
echo 'Types: deb' > /etc/apt/sources.list.d/debian.sources
echo 'URIs: http://mirrors.tuna.tsinghua.edu.cn/debian' >> /etc/apt/sources.list.d/debian.sources
echo "Suites: ${CODENAME} ${CODENAME}-updates" >> /etc/apt/sources.list.d/debian.sources
echo 'Components: main contrib non-free non-free-firmware' >> /etc/apt/sources.list.d/debian.sources
echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
echo '' >> /etc/apt/sources.list.d/debian.sources
echo 'Types: deb' >> /etc/apt/sources.list.d/debian.sources
echo 'URIs: http://mirrors.tuna.tsinghua.edu.cn/debian-security' >> /etc/apt/sources.list.d/debian.sources
echo "Suites: ${CODENAME}-security" >> /etc/apt/sources.list.d/debian.sources
echo 'Components: main contrib non-free non-free-firmware' >> /etc/apt/sources.list.d/debian.sources
echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
else
cp /etc/apt/sources.list /etc/apt/sources.list.old
echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian ${CODENAME} main contrib non-free non-free-firmware" > /etc/apt/sources.list
echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian ${CODENAME}-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list
echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian-security ${CODENAME}-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list
fi

apt update
apt install -y ca-certificates

if [ -f "/etc/apt/sources.list.d/debian.sources" ];then
echo 'Types: deb' > /etc/apt/sources.list.d/debian.sources
echo 'URIs: https://mirrors.tuna.tsinghua.edu.cn/debian' >> /etc/apt/sources.list.d/debian.sources
echo "Suites: ${CODENAME} ${CODENAME}-updates" >> /etc/apt/sources.list.d/debian.sources
echo 'Components: main contrib non-free non-free-firmware' >> /etc/apt/sources.list.d/debian.sources
echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
echo '' >> /etc/apt/sources.list.d/debian.sources
echo 'Types: deb' >> /etc/apt/sources.list.d/debian.sources
echo 'URIs: https://mirrors.tuna.tsinghua.edu.cn/debian-security' >> /etc/apt/sources.list.d/debian.sources
echo "Suites: ${CODENAME}-security" >> /etc/apt/sources.list.d/debian.sources
echo 'Components: main contrib non-free non-free-firmware' >> /etc/apt/sources.list.d/debian.sources
echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
else
echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian ${CODENAME} main contrib non-free non-free-firmware" > /etc/apt/sources.list
echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian ${CODENAME}-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list
echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security ${CODENAME}-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list
fi

apt update
apt clean
rm -rf /var/lib/apt/lists/*
S
```

</details>

  * [1. tool](assets/docs/AI/Linux/debian.md)
  * [2. go AND pip](assets/docs/AI/Linux/go.md)
  * [3. WebDAV](assets/docs/AI/Linux/webdav.md)

<details>
<summary></summary>

(/// ### )

* [Bitwarden](https://bitwarden.com/)
* [KeePass](https://keepass.info/)

```bash
# 解压单个.tar.gz文件
tar -zxvf amd.tar.gz
# 解压所有.tar.gz文件
# for tar in *.tar.gz;  do tar xvf $tar; done
# 安装所有 deb 文件
# sudo dpkg -i *.deb
# 使用自定义的 bash 脚本
./restore_g.sh g_backup_*.tar.gz
```

```bash
# 本地仓库同步到远程仓库
# 查看当前已配置远程仓库
git remote -v
# 删除当前远程仓库如果有
git remote remove origin
# 查看当前本地分支
git branch
# 添加远程仓库
git remote add git@github.com:HanamiSakiP/docs.git
# 切换到本地master分支
git switch master
# 本地分支强制重置成远程分支
git reset --hard origin/master
```
```bash
# 首次git
git init
# origin为远程仓库名
git remote add origin git@github.com:HanamiSakiP/docs.git
git add .
git commit -m "frist"
# 首次需要添加 -u origin master
git push -u origin master
git push # 后续使用
```

android 使用 termux
* [android-termux](https://github.com/termux/termux-app/releases/)

来听歌

[restore](assets/docs/images/1-happylife.mp4 ':include')

</details>
