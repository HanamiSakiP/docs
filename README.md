<div align="center">
  <h1 align="center">
    <a href="/luJTwX54bBjJ7R1f5lkd7gQ" title="关注塔菲喵">
      <img src="assets/docs/images/M.jpg" width="200" alt="">
    </a>
    <br/>
    Documents
  </h1>
</div>

## 简介

* start
```bash
mkdir -p ~/.local/share/devmgr/backups
git -C ~/.local/share/devmgr clone https://github.com/HanamiSakiP/AI.git
```
```bash
mkdir -p ~/.local/bin
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
cp -r ~/.local/share/devmgr/AI/dev/backups ~/.local/share/devmgr/
install -m755 ~/.local/share/devmgr/AI/dev/dev ~/.local/bin
install -m755 ~/.local/share/devmgr/AI/dev/dev-tool ~/.local/bin
install -m755 ~/.local/share/devmgr/AI/dev/tool ~/.local/bin
install -m755 ~/.local/share/devmgr/AI/dev/undev ~/.local/bin
install -m755 ~/.local/share/devmgr/AI/dev/doc ~/.local/bin
dev restore # install
dev-tool
source ~/.bashrc
```

<details>
<summary>test</summary>

apt
```bash
apt update
apt install curl git -y # nano
```
```bash
# 数据库MCP
npx @dbx-app/mcp-server
# 1. 浏览器
npm install puppeteer-core
git clone https://github.com/h4ckf0r0day/obscura.git
cd obscura
# Rendering
cargo build --release -p obscura-cli --bins --features render
# 查看 rust 工具
cargo install --list
cargo install --locked starship
cargo install --locked navi
cargo install --locked zellij
cargo install jj-cli
cargo install lsd
cargo install binsider
cargo install microsandbox
cargo install lychee
cargo install code2prompt
cargo install --force --git https://github.com/sxyazi/yazi.git yazi-build
cargo install --force --git https://github.com/RightNow-AI/openfang openfang-cli
cargo install --git https://github.com/ekzhang/sshx --bin sshx
```
```bash
eval "$(starship init bash)"
function y() {
local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
command yazi "$@" --cwd-file="$tmp"
IFS= read -r -d '' cwd < "$tmp"
[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
command rm -f -- "$tmp"
}
```
```bash
cat >> ~/.cargo/config.toml << 'EOF'
[net]
git-fetch-with-cli = true
EOF
rm -rf ~/.cargo/git ~/.cargo/registry
```
```bash
CARGO_TARGET_DIR=~/.cargo-target 
docsify serve .
# 每天02点执行rclone同步
0 2 * * * flock -n /tmp/rclone.lock ~/go/bin/rclone sync /本地/路径 remote:云端路径 --log-file /home/你的用户名/rclone-sync.log --log-level INFO
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
