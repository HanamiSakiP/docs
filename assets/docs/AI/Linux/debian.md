# tool

```bash
# skill -> 技能知识
# mcp -> 工具感官
# 数据库MCP
npx @dbx-app/mcp-server
# 查看当前用户仓库
gh repo list
```
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python main.py
deactivate
```
```bash
source .venv/bin/activate
python main.py
# deactivate
```
```bash
# git配置ssh
git config --global user.name "hanamisakip"
git config --global user.email "你的邮箱@example.com"
ssh-keygen -t rsa -b 4096 -C "你的邮箱@example.com"
cat ~/.ssh/id_rsa.pub
# 查看已配置的远程仓库,名称 + 对应 URL
git remote -v
# 查看单个远程仓库的详细信息
git remote show origin  # 替换 origin 为你的远程仓库简称
```
```bash
# 创建会话和后台输出命令
tmux new-session -d -s name
tmux send-keys -t name "mkdir demo" Enter
# 查询会话
tmux ls
```
```bash
# 删除会话
tmux kill-session -t name
```
```bash
cat >> ~/.cargo/config.toml << 'EOF'
[net]
git-fetch-with-cli = true
EOF
rm -rf ~/.cargo/git ~/.cargo/registry
# 
CARGO_TARGET_DIR=~/.cargo-target 
```
## Ollama
```bash
# 一键安装
# curl -fsSL https://ollama.com/install.sh | sh
# 手动安装ollama.tar.zst
# curl -fsSL https://ollama.com/download/ollama-linux-amd64.tar.zst
sudo tar --zstd -xf /home/user/ollama-linux-amd64.tar.zst -C /usr
# 设置
sudo useradd -r -s /bin/false -U -m -d /usr/share/ollama ollama
sudo usermod -a -G ollama $(whoami)
sudo nano /etc/systemd/system/ollama.service
```
```ollama.service
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
Environment="PATH=$PATH"

[Install]
WantedBy=multi-user.target
```
```bash
sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl start ollama
sudo systemctl status ollama
```
```bash
# 查看版本
ollama -v
# 开启服务
ollama server
# 查询服务是否启动
curl 127.0.0.1:11434 # 成功返回 Ollama is running
# 查看已下载模型
ollama list
# 下载模型
ollama pull qwen3.5:0.8b
# 使用模型(无则会进行下载)
ollama run qwen3.5:0.8b
```


<details>
<summary>省流</summary>

```bash
# windows
# go env -w GOPROXY=https://goproxy.cn,direct
# go env -w GO111MODULE=on
# linux
export GOPROXY=https://goproxy.cn,direct
```
```bash
go install filippo.io/age/cmd/...@latest
go install github.com/maaslalani/nap@main
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

* [浏览器夜间插件](https://addons.mozilla.org/firefox/addon/dark-background-light-text/)
```text
#ffffff
#241f31
#deddda
#9a9996
#ff0000
#8080ff
```

* [显卡n卡驱动](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/)