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
install -m755 ~/.local/share/devmgr/AI/dev/dev-tool ~/.local/bin
install -m755 ~/.local/share/devmgr/AI/dev/tool ~/.local/bin
install -m755 ~/.local/share/devmgr/AI/dev/undev ~/.local/bin
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
dev restore # install
dev-tool
tool
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
docker cp ~/.local/share/devmgr/AI test-debian:/root/.local/share/devmgr/AI
docker exec -it test-debian /bin/bash
# 强制删除容器
# docker rm -f test-debian
```
podman
```bash
podman run -d --name test-debian debian:latest sleep infinity
podman exec -it test-debian mkdir -p /root/.local/share/devmgr/devmgr/AI
podman cp ~/.local/share/devmgr/AI test-debian:/root/.local/share/devmgr/AI
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
docsify serve .
# 每天02点执行rclone同步
0 2 * * * flock -n /tmp/rclone.lock ~/go/bin/rclone sync /本地/路径 remote:云端路径 --log-file /home/你的用户名/rclone-sync.log --log-level INFO
# 安装tui工具
gh release download --repo denisidoro/navi --pattern "*x86_64-unknown-linux-musl*"
gh release download --repo sxyazi/yazi --pattern "*x86_64-unknown-linux-musl*"
gh release download --repo zellij-org/zellij --pattern "*x86_64-unknown-linux-musl*"
```

</details>

  * [1. tool](assets/docs/AI/Linux/debian.md)
  * [2. WebDAV](assets/docs/AI/Linux/webdav.md)

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
