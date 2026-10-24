常用的 Linux 命令：

### docker配置相关
1. **tar.gz文件** - 解压单个
```bash
tar -zxvf 压缩文件名.tar.gz
```
例子:
```bash
tar -zxvf Debian_docker.tar_amd64.gz
```
2. **tar.gz文件** - 解压所有.tar.gz压缩包
```bash
for tar in *.tar.gz;  do tar xvf $tar; done
```
3. **dpkg包管理** - 安装所有deb文件
```bash
sudo dpkg -i *.deb
```

4. **docker配置1** - 创建目录(需要再配置)
```bash
mkdir -p /etc/docker
cp ~/.local/share/devmgr/AI/dev/tools/docker/daemon.json /etc/docker
```
```bash
# 重启后生效
sudo service docker restart # start / stop
```

<details>
<summary>docker镜像源及存储路径json配置</summary>

* 3个镜像源
* 默认储存路径 /new/docker 
```daemon.json
{
	"registry-mirrors": [
	"https://docker.xuanyuan.me",
	"https://docker.1ms.run",
	"https://hub.rat.dev"],
	"data-root": "/new/docker"
}
```

</details>

### docker权限和所有
1. **docker保存打包镜像** - docker save
```bash
docker save -o <指定文件名称.tar> <镜像名称>
```
2. **docker读取打包镜像** - docker load
```bash
docker load -i <载入文件名称.tar>
```
3. **docker拷贝文件** - 容器内拷贝到本机
```bash
docker cp <容器ID或名称>:<容器路径> <本地文件路径>
```

### 文件和目录操作
1. **ls** - 列出目录内容
   ```bash
   ls
   ls -l  # 详细列表
   ls -a  # 包括隐藏文件
   ```

2. **cd** - 切换目录
   ```bash
   cd /path/to/directory
   cd ..  # 返回上一级目录
   cd ~   # 返回家目录
   ```

3. **pwd** - 显示当前工作目录
   ```bash
   pwd
   ```

4. **mkdir** - 创建目录
   ```bash
   mkdir new_directory
   ```

5. **rmdir** - 删除空目录
   ```bash
   rmdir directory
   ```

6. **rm** - 删除文件或目录
   ```bash
   rm file
   rm -r directory  # 递归删除目录
   ```

7. **cp** - 复制文件或目录
   ```bash
   cp source destination
   cp -r source_directory destination_directory  # 递归复制目录
   ```

8. **mv** - 移动或重命名文件或目录
   ```bash
   mv source destination
   ```

9. **touch** - 创建空文件或更新文件时间戳
   ```bash
   touch file
   ```

10. **cat** - 查看文件内容
    ```bash
    cat file
    ```

11. **more** / **less** - 分页查看文件内容
    ```bash
    more file
    less file
    ```

12. **head** / **tail** - 查看文件开头或结尾部分
    ```bash
    head file
    tail file
    tail -f file  # 实时查看文件新增内容
    ```

### 文件权限和所有权
1. **chmod** - 修改文件权限
   ```bash
   chmod 755 file
   chmod +x file  # 添加执行权限
   ```

2. **chown** - 修改文件所有者
   ```bash
   chown user:group file
   ```

3. **chgrp** - 修改文件所属组
   ```bash
   chgrp group file
   ```

### 系统信息
1. **uname** - 显示系统信息
   ```bash
   uname -a
   ```

2. **df** - 显示磁盘空间使用情况
   ```bash
   df -h
   ```

3. **du** - 显示目录或文件的磁盘使用情况
   ```bash
   du -sh directory
   ```

4. **top** / **htop** - 显示系统进程和资源使用情况
   ```bash
   top
   htop
   ```

5. **ps** - 显示当前进程状态
   ```bash
   ps aux
   ```

6. **kill** - 终止进程
   ```bash
   kill PID
   kill -9 PID  # 强制终止
   ```

### 网络操作
1. **ping** - 测试网络连接
   ```bash
   ping example.com
   ```

2. **ifconfig** / **ip** - 显示或配置网络接口
   ```bash
   ifconfig
   ip addr show
   ```

3. **netstat** - 显示网络连接、路由表、接口统计等
   ```bash
   netstat -tuln
   ```

4. **ssh** - 远程登录
   ```bash
   ssh user@host
   ```

5. **scp** - 安全复制文件
   ```bash
   scp file user@host:/path/to/destination
   ```

6. **wget** / **curl** - 下载文件
   ```bash
   wget http://example.com/file
   curl -O http://example.com/file
   ```

### 包管理
1. **apt** (Debian/Ubuntu)
   ```bash
   sudo apt update
   sudo apt install package
   sudo apt remove package
   ```

2. **yum** (CentOS/RHEL)
   ```bash
   sudo yum install package
   sudo yum remove package
   ```

3. **dnf** (Fedora)
   ```bash
   sudo dnf install package
   sudo dnf remove package
   ```

4. **pacman** (Arch Linux)
   ```bash
   sudo pacman -S package
   sudo pacman -R package
   ```

### 其他常用命令
1. **grep** - 文本搜索
   ```bash
   grep pattern file
   ```

2. **find** - 查找文件
   ```bash
   find /path -name "filename"
   ```

3. **tar** - 打包和解包文件
   ```bash
   tar -cvf archive.tar files
   tar -xvf archive.tar
   ```

4. **zip** / **unzip** - 压缩和解压缩文件
   ```bash
   zip archive.zip files
   unzip archive.zip
   ```

5. **sed** - 流编辑器
   ```bash
   sed 's/old/new/' file
   ```

6. **awk** - 文本处理工具
   ```bash
   awk '{print $1}' file
   ```

7. **alias** - 创建命令别名
   ```bash
   alias ll='ls -la'
   ```

8. **history** - 显示命令历史
   ```bash
   history
   ```

这些命令涵盖了 Linux 系统中的基本操作，掌握它们可以帮助你更高效地管理和使用 Linux 系统。