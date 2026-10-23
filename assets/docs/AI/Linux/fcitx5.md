> ## 下载fcitx5及中文拼音包
> ```bash
> sudo apt install fcitx5 fcitx5-chinese-addons
> sudo apt install libreoffice-l10n-zh-cn
> ```
>  ## 1. 主题下载安装
> * [fcitx5主题](https://github.com/thep0y/fcitx5-themes-candlelight)
> ```bash
> git clone https://github.com/thep0y/fcitx5-themes-candlelight.git
> mkdir -p ~/.local/share/fcitx5/themes
> cd fcitx5-themes-candlelight
> cp -r macOS-dark ~/.local/share/fcitx5/themes/
> vim ~/.config/fcitx5/conf/classicui.conf
> ```
>  ## 2. 主题配置（classicui.conf）
> ```bash
> # 垂直候选列表
> Vertical Candidate List=False
> # 按屏幕 DPI 使用
> PerScreenDPI=True
> # Font (设置成你喜欢的字体)
> Font="Smartisan Compact CNS 22"
> # 主题(这里要改成你想要使用的主题名，主题名就在下面)
> Theme=macOS-dark
> ```
>  ## 3. 快速输入
> * 配置 -> 附加组件 -> 快速输入 -> 配置 -> 添加/导入
>    * 键盘按 v   + 关键词触发
> ```bash
> # 我的词组配置
> ol	"ollama list"
> op	"ollama pull "
> dp	"docker ps"
> di	"docker images"
> ds	"docker start id"
> ds	"docker stop id"
> dcp	"docker compose ps"
> ad	"adk run\n"
> ad	"adk web "
> ad	"adk api_server --a2a --port 9999 "
> gi	"git add . && git commit -m \" AI\" && git push"
> ```

<details>
<summary>tools</summary>

```bash
# go-cn(windows)
go env -w GOPROXY=镜像网站,direct
go env -w GO111MODULE=on
```
```bash
# linux
export GOPROXY=https://goproxy.cn,direct
```
```bash
go install filippo.io/age/cmd/...@latest
go install github.com/maaslalani/nap@main
go install github.com/charmbracelet/glow@latest
go install github.com/boyter/scc/v3@latest
go install github.com/zu1k/nali@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/gopasspw/gopass@latest
go install github.com/LeperGnome/bt/cmd/bt@v1.2.0
go install github.com/aurc/loggo@latest
go install github.com/knqyf263/sou@latest
go install github.com/dhth/omm@latest
go install github.com/neilotoole/sq@latest
go install github.com/rs/curlie@latest
go install github.com/xo/usql@latest
go install github.com/projectdiscovery/katana/cmd/katana@latest
# test
go install github.com/brittonhayes/pillager@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
env CGO_ENABLED=0 go install -ldflags="-s -w" github.com/gokcehan/lf@latest
```
```bash
pip install httpie
pip install pathos
pip install toolong
pipx run nvitop
# uvx nvitop
python -m pip install aider-install
aider-install
```

</details>

<details>
<summary>镜像源</summary>

```bash
# go临时
export GOPROXY=https://goproxy.cn,direct
nrm use huawei
# 查看当前pip源
pip config list
# 查看当前git源
git config --global -l | grep insteadOf
# 全局配置git
git config --global url."https://ghproxy.com/https://github.com/".insteadOf "https://github.com/"
# 取消这个镜像
git config --global --unset url."https://ghproxy.com/https://github.com/"
```

</details>

<details>
<summary></summary>

```bash
# 密钥生成
age-keygen -o key.txt
# 密钥解密
age -d -i key.txt -o 还原后的文件  加密的文件
# 密钥加密
age -p -i key.txt -o 加密后的文件  加密前的文件

# 加密
age -p -o secret.age secret.txt
# 解密
age -d  -o secret.txt secret.age
```

```bash
# rclone配置
rclone config
# n , 名字 , 服务
# 回车,回车,n,y,浏览器登陆,y
# 查看已配置的rclone
rclone listremotes
# 查看rclone内容(目录)
rclone lsd k:

# 快照查看
restic -r rclone:k:apk snapshots
# 查看快照内容(全部)
restic -r rclone:k:apk ls ID
# 查看快照某个内容
restic -r rclone:k:apk ls ID --path apk/debian
# 恢复快照中某个文件夹到本地(.表示当前目录)
restic -r rclone:k:apk restore latest --target apk --include .
```

```bash
# restic 仓库初始化
restic init -r o/apk
# restic 仓库备份( test 文件夹)
restic -r o/apk backup test
# 模拟增量同步 --progress（显示进度）
rclone sync o/apk k:apk --progress --dry-run
# 增量同步( o/apk 为本地目录)
rclone sync o/apk k:apk --progress
# restic 恢复快照中 test 文件夹到本地(.表示当前目录) (latest表示最新的快照ID)
restic -r o/apk restore latest --target test --include .

# 删除快照
restic forget ID
```

</details>