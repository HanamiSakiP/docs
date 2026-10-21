# webdav

> [![](../../../../assets/docs/images/wr1.jpg)](https://koofr.eu/ "推荐webdav官网filedn.eu/")
> * [koofr 官方 WebDAV URL](https://app.koofr.net/dav/Koofr)
> * [koofr 挂载 Dropbox WebDAV URL](https://app.koofr.net/dav/Dropbox)

## rclone省流
> ```bash
> rclone config
> # n , 名字 , 服务
> # 回车,回车,n,y,浏览器登陆,y
> # 列出所有远程的名称
> rclone listremotes
> # 测试连通性
> rclone lsd dropbox:
> # 初始化,备份,恢复
> ```

## git省流使用

<details>
<summary>情况0,未配置gh</summary>

```bash
# 使用 token 文件登陆（需要提前创建）
gh auth login --with-token < mytoken.txt
# 查看 gh 当前用的协议
gh auth status
```
```bash
# 浏览器登陆
gh auth login --web
# 查看 GitHub 上已上传公钥
gh ssh-key list
```
</details>

<details>
<summary>情况1,未创建本地/远程git仓库</summary>

```bash
# 1. 创建 git 本地仓库
git init # 初始化当前目录
```
```bash
# 1.1. 使用 gh 创建新远程仓库-github
# 创建名为 my-project 的私有仓库，并立即克隆到本地
gh repo create my-project --private --clone
```
```bash
# 1.1.1. 基于模板，创建新远程仓库
# 基于 owner/template-repo 模板，
# 创建名为 my-project 的公开仓库，并立即克隆到本地
gh repo create my-new-repo --template owner/template-repo --public --clone
```

</details>

```bash
# 2. 提交更改
# 查看当前 分支
git branch -vv
# 查看当前远程仓库
git remote -v
# 切换到 main 分支
# git branch -M main
# 添加暂存
git add .
git commit -m "first commit"
git push
```
<details>
<summary>情况2,已创建本地git仓库</summary>

```bash
# 3. 将git本地推送到远程
# 在本地项目根目录下执行
# 3.1 使用 git 添加远程仓库 -> 提交更改 <-
git remote add origin git@github.com:HanamiSakiP/docs.git
```
```bash
# 3.2 直接使用 gh 推送
gh repo create docs --public --source=. --push
```

</details>

<details>
<summary>情况3,已创建远程git仓库</summary>

```bash
# 4. 下载远程仓库到本地
# 使用git
git clone https://github.com/HanamiSakiP/AI.git
```
```bash
# 使用gh
gh repo clone HanamiSakiP/AI
```

</details>

## rclone
> ### 1. 初始化交互
> ```bash
> rclone config
> ```
> ### 2. 列出已配置
> ```bash
> rclone listremotes
> ```
> ### 3. 列出 remote 根目录
> ```bash
> rclone ls remote:bucket/path
> rclone lsd remote:bucket/path      # 只列目录
> rclone lsf remote:bucket/path      # 简洁列表（可用参数定制）
> ```
> 从本地复制到 remote（保留源文件）
> ```bash
> rclone copy /local/path remote:bucket/path
> ```
> ### 4. 从 remote 复制到本地
> ```bash
> # remote:bucket/path 为远程仓库
> rclone copy remote:bucket/path /local/path
> ```
> ### 5. 同步（目标被源完全覆盖 — 会删除目标多余文件）
> ```bash
> rclone sync /local/path remote:bucket/path
> ```
> ### 5.1 增量同步（仅修改或新增文件）通常由 copy 实现；sync 强制镜像
> 可加参数：-v（详细），--progress（显示进度），--dry-run（模拟执行），--checksum（使用校验和），--size-only（仅比较大小），--delete-excluded（删除排> 除项之外的文件）等。
> ```bash
> rclone sync /local/photos remote:backup/photos --progress --dry-run
> ```
> 移动
> ```bash
> rclone move /local/path remote:bucket/path
> ```
> 在 remote 内重命名（实际上是复制+删除）
> ```bash
> rclone moveto remote:bucket/oldname remote:bucket/newname
> ```
> 删除 remote 中的文件或目录
> ```bash
> rclone delete remote:bucket/path        # 删除文件
> rclone purge remote:bucket/path         # 删除目录及其内容
> rclone rmdirs remote:bucket/path        # 删除空目录
> ```
> ### 6. 比较两端差异（列出不同文件）
> ```bash
> rclone check /local/path remote:bucket/path
> rclone md5sum remote:bucket/path > remote_md5.txt   # 生成校验和（视 backend 支持）
> ```
> 挂载（FUSE，Linux/macOS/Windows with WinFsp）
> 常用参数：--vfs-cache-mode full|writes|off，--allow-other（允许其他用户访问），--uid/--gid，--read-only。
> ```bash
> rclone mount remote:bucket /mnt/remote --vfs-cache-mode writes
> ```
> 搜索文件名包含关键字
> ```bash
> rclone find remote:bucket/path --name "关键字"
> ```

## git使用

> ### 1、新建仓库
> 登陆账号后点+号new
>  * [新建仓库](https://github.com/new/)
>  * Repository name处输入仓库名
>  * Quick setup — if you’ve done this kind of thing before
>     + 下方点击ssh（2-2要用）


> ### 2、生成 SSH 密钥并使用
> ```bash
> ssh-keygen -t rsa -b 4096 -C "你的邮箱@example.com"
> ```
>  会出现以下提示（确认密钥保存的默认路径）
> ```bash提示
> # 回车就好
> Enter file in which to save the key (/home/user/.ssh/id_rsa): 
> ```
> 回车后输入密码，再确认
> ```bash
> 查看生成的密钥（复制到GitHub上）
> cat ~/.ssh/id_rsa.pub
> ```
> 复制内容登录到 GitHub，进入 "Settings" > "SSH and GPG keys"，点击 "New SSH key"，粘贴公钥并保存。



> ### 3、git初体验
> #### 步骤 1: 初始化 Git 仓库
> 如果您还没有在文件夹中初始化 Git 仓库，请在终端中导航到该文件夹并运行以下命令：
> ```bash
> cd /path/to/your/folder
> git init
> ```
> 这将创建一个新的 Git 仓库。
> #### 步骤 2: 添加远程仓库
> 如果您还没有将远程仓库添加到本地仓库，请使用以下命令：
> ```bash
> # origin为远程仓库名(任意设置)
> git remote add origin git@github.com:username/repository.git
> ```
> 将 `username` 和 `repository` 替换为您的 GitHub 用户名和仓库名称。
> #### 步骤 3: 添加所有文件和文件夹
> 要添加文件夹内的所有文件和子文件夹，可以使用以下命令：
> ```bash
> git add .
> ```
> 这个命令会将当前目录下的所有文件和文件夹添加到 Git 的暂存区。
> #### 步骤 4: 提交更改
> 在添加文件后，您需要提交更改：
> ```bash
> git commit -m "Initial commit with all files"
> ```
> 您可以根据需要更改提交信息。
> #### 步骤 5: 推送到 GitHub
> 最后，将更改推送到 GitHub：
> ```bash
> git push -u origin master
> ```

### end. 点击创建好的仓库pages
> * [设置](https://github.com/用户名/仓库名/settings/pages)
    > * 找到
     > *GitHub Pages* 下的 *Branch*  下面 *None*  改为 *master*    /root
    *  点Save保存
> ```bash
> docsify serve docs/
> ```
