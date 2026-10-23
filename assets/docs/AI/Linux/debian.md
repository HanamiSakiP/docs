## lang版本控制
* [go](https://github.com/voidint/g)
* [node](https://github.com/nvm-sh/nvm)
* [python](https://github.com/pyenv/pyenv)

<details>
<summary>省流</summary>

恢复(mytoken.txt)
```bash
# 设置git
git config --global user.name "hanamisakip"
git config --global user.email "你的邮箱@example.com"
ssh-keygen -t rsa -b 4096 -C "你的邮箱@example.com"
cat ~/.ssh/id_rsa.pub
# gh login
gh auth login --with-token < mytoken.txt
# echo "你的令牌" | gh auth login --with-token
# add SSH
gh ssh-key add ~/.ssh/id_rsa.pub -t "test"
# 如果缺少权限
# gh auth refresh -h github.com -s admin:public_key
# https://github.com/login/device
# 查看仓库(用户名/仓库名)
gh repo list
# 批量克隆10个仓库(最多1000个)
gh repo list --limit 10 --json nameWithOwner --jq '.[].nameWithOwner' | xargs -L1 gh repo clone
```

</details>

## git AND tmux

### tmux
```bash
# 创建会话和后台输出命令
tmux new-session -d -s mcp_server
tmux send-keys -t mcp_server "go run /path/mcp_server/." Enter
tmux new-session -d -s a2a_server
tmux send-keys -t mcp_server "go run /path/a2a_server/." Enter
tmux new-session -d -s a2a_client
tmux send-keys -t mcp_server "go run /path/a2a_client/." Enter
# 查询会话
tmux ls
```
```bash
# 删除会话
tmux kill-session -t mcp_server
tmux kill-session -t a2a_server
tmux kill-session -t a2a_client
```

### git
```bash
# 下载项目
git clone 地址  指定目录(没有设置则默认当前目录)
# 查看已配置的远程仓库,名称 + 对应 URL
git remote -v
# 查看单个远程仓库的详细信息
git remote show origin  # 替换 origin 为你的远程仓库简称
```
git SSH_Config
```bash
git config --global user.name "hanamisakip"
git config --global user.email "你的邮箱@example.com"
ssh-keygen -t rsa -b 4096 -C "你的邮箱@example.com"
cat ~/.ssh/id_rsa.pub
# gh login
gh auth login --with-token < mytoken.txt
# echo "你的令牌" | gh auth login --with-token
# add SSH
gh ssh-key add ~/.ssh/id_rsa.pub -t "test"
```

<details>
<summary>git 后续使用</summary>


 git 后续使用
```bash
# 添加子模块
git submodule add https://github.com/iphysresearch/GWToolkit.git GWToolkit
# 初始化更新子模块
git submodule update --init --recursive
# 查看当前状态
git status
```
* 此时已生成了.gitmodules 显示如下
```text
$ git status
位于分支 main
您的分支与上游分支 'origin/main' 一致。
要提交的变更：
  （使用 "git restore --staged <文件>..." 以取消暂存）
	新文件：   .gitmodules
	新文件：   GWToolkit
```
```bash
# 查看子模块
git submodule
# 更新项目内子模块到最新版本
git submodule update
# 更新子模块为远程项目的最新版本
git submodule update --remote
# 1. 删除子模块文件夹
git rm --cached GWToolkit
rm -rf GWToolkit

2. 删除 .gitmodules 文件中相关子模块的信息，类似于：
```text
[submodule "GWToolkit"]
        path = GWToolkit
        url = https://github.com/iphysresearch/GWToolkit.git
```

3. 删除 .git/config 中相关子模块信息，类似于：
```text
[submodule "GWToolkit"]
        url = https://github.com/iphysresearch/GWToolkit.git
        active = true
```
 
4. 删除 .git 文件夹中的相关子模块文件
```bash
rm -rf .git/modules/GWToolkit
```text
```

</details>

## 3. Ollama安装与命令
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
