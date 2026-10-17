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
git clone https://github.com/HanamiSakiP/AI.git && cd AI
chmod +x *.sh && ./install
exec bash
docsify serve .
```

<details>
<summary>test</summary>

docker
```bash
docker pull debian
# 精简版debian
docker pull debian:trixie-slim
podman run -it --name my-debian debian:latest /bin/bash
podman start -ai my-debian
# 强制删除容器
# podman rm -f debian-test
# 按标签删除镜像
# podman rmi debian:latest
# 或者按 ID 删除镜像
# podman rmi 99339bdd341a
# 复制文件出当前目录
podman cp my-debian:/AI ./
```
apt
```bash
apt update
apt install curl git nano
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
镜像源
```bash
# go
export GOPROXY=https://goproxy.cn,direct
# npm
npm install docsify-cli -g --registry=https://registry.npmmirror.com
# python
pip install httpie -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
```

</details>

<details>
<summary>tools</summary>

node
```bash
npm i docsify-cli -g
npm install -g @opencode/cli
npm install -g @openai/codex
npm install -g @anthropic-ai/claude-code
# go
go install github.com/restic/restic/cmd/restic@latest
go install github.com/rclone/rclone@latest
go install github.com/junegunn/fzf@latest
# GitHub
go install github.com/cli/cli/v2/cmd/gh@latest
# GitLab
go install gitlab.com/gitlab-org/cli/cmd/glab@latest
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
android 使用 termux
* [android-termux](https://github.com/termux/termux-app/releases/)

来听歌

[restore](assets/docs/images/1-happylife.mp4 ':include')

</details>
