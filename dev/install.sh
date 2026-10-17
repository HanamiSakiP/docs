#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ========== 脚本位置 ==========
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# ========== 环境初始化 ==========
export PS1="${PS1:-\\u@\\h:\\w\\$ }"
export debian_chroot="${debian_chroot:-}"
export force_color_prompt="${force_color_prompt:-yes}"
export GOPATH="${GOPATH:-$HOME/go}"

# ========== 颜色定义 ==========
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ========== 日志函数 ==========
log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

# ========== 国内镜像配置 ==========
USE_CN_MIRROR="${USE_CN_MIRROR:-0}"
# github 代理前缀，用于 git clone 以及 g 安装脚本内部的 release 下载
CN_GITHUB_PROXY="${CN_GITHUB_PROXY:-https://ghproxy.net/}"
# nvm 安装 node 时使用的镜像（写入 ~/.bashrc）
CN_NODE_MIRROR="${CN_NODE_MIRROR:-https://npmmirror.com/mirrors/node}"
# g 安装 go 时使用的镜像（写入 ~/.bashrc）
CN_GO_MIRROR="${CN_GO_MIRROR:-https://golang.google.cn/dl/}"
# pyenv 编译 python 时使用的源码镜像（写入 ~/.bashrc）
CN_PYTHON_MIRROR="${CN_PYTHON_MIRROR:-https://registry.npmmirror.com/-/binary/python}"

# ========== 用法 ==========
usage() {
  cat <<'EOF'
用法: install.sh [选项] [工具...]

工具（不传则默认 all）:
  all       安装全部（pyenv / g / nvm）
  pyenv     仅安装 pyenv
  g         仅安装 g
  nvm       仅安装 nvm

选项:
  --cn, -c       使用国内镜像源（等价于 USE_CN_MIRROR=1）
  --no-restore   跳过本地备份恢复，强制在线安装
  -h, --help     显示本帮助

环境变量:
  USE_CN_MIRROR=1            启用国内镜像源
  CN_GITHUB_PROXY=<url>      github 代理前缀，默认 https://ghfast.top/
  CN_NODE_MIRROR=<url>       node 镜像，默认 https://npmmirror.com/mirrors/node
  CN_GO_MIRROR=<url>         go 镜像，默认 https://golang.google.cn/dl/
  CN_PYTHON_MIRROR=<url>     python 源码镜像
  SKIP_LOCAL_RESTORE=1       跳过本地备份恢复

示例:
  ./install.sh                   安装全部（优先使用本地备份）
  ./install.sh --cn              国内源安装全部
  ./install.sh pyenv             仅安装 pyenv
  ./install.sh --cn g nvm        国内源安装 g 和 nvm
  CN_GITHUB_PROXY=https://ghproxy.net/ ./install.sh --cn g
EOF
}

# ========== 配置写入函数 ==========
add_config() {
  local file="$1"
  local content="$2"
  touch "$file"
  if ! grep -qF -- "$content" "$file"; then
    echo "正在配置 $file..."
    echo "$content" >> "$file"
  else
    echo "跳过 $file（配置已存在）"
  fi
}

# ========== 环境配置写入 & 当前进程生效（安装/恢复共用） ==========
write_pyenv_config() {
  local pyenv_configs=(
    'export PYENV_ROOT="$HOME/.pyenv"'
    '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
    'eval "$(pyenv init - bash)"'
  )
  for line in "${pyenv_configs[@]}"; do
    add_config "$HOME/.bashrc" "$line"
    add_config "$HOME/.profile" "$line"
  done
  if [[ "$USE_CN_MIRROR" == "1" ]]; then
    add_config "$HOME/.bashrc" "export PYTHON_BUILD_MIRROR_URL=\"$CN_PYTHON_MIRROR\""
    add_config "$HOME/.bashrc" "export PYTHON_BUILD_MIRROR_URL_SKIP_CHECKSUM=1"
  fi
}

write_g_config() {
  local g_configs=(
    'export GOROOT="$HOME/.g/go"'
    'export PATH="$HOME/.g/bin:$GOROOT/bin:$PATH"'
    '[ -s "$HOME/.g/env" ] && \. "$HOME/.g/env"  # g shell setup'
  )
  for line in "${g_configs[@]}"; do
    add_config "$HOME/.bashrc" "$line"
    add_config "$HOME/.profile" "$line"
  done
  if [[ "$USE_CN_MIRROR" == "1" ]]; then
    add_config "$HOME/.bashrc" "export G_MIRROR=\"$CN_GO_MIRROR\""
  fi
}

write_nvm_config() {
  local nvm_lines=(
    'export NVM_DIR="$HOME/.nvm"'
    '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
    '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
  )
  for line in "${nvm_lines[@]}"; do
    add_config "$HOME/.bashrc" "$line"
    add_config "$HOME/.profile" "$line"
  done
  if [[ "$USE_CN_MIRROR" == "1" ]]; then
    add_config "$HOME/.bashrc" "export NVM_NODEJS_ORG_MIRROR=\"$CN_NODE_MIRROR\""
  fi
}

apply_pyenv_env() {
  export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
  [[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - bash)" 2>/dev/null || true
}

apply_g_env() {
  export GOROOT="$HOME/.g/go"
  if [[ -s "$HOME/.g/env" ]]; then
    # shellcheck disable=SC1091
    \. "$HOME/.g/env" 2>/dev/null || true
  fi
  # 显式覆盖，防止 .g/env 内容异常导致 PATH 丢失
  export PATH="$HOME/.g/bin:$GOROOT/bin:$PATH"
  mkdir -p "$GOPATH"/{bin,src,pkg}
}

apply_nvm_env() {
  export NVM_DIR="$HOME/.nvm"
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # shellcheck disable=SC1091
    \. "$NVM_DIR/nvm.sh"
  fi
  if [[ -s "$NVM_DIR/bash_completion" ]]; then
    # shellcheck disable=SC1091
    \. "$NVM_DIR/bash_completion"
  fi
}

# ========== 本地备份探测（用于优先恢复） ==========
# 支持两种存放结构：
#   1) <script_dir>/dev/tools/<tool>/<tool>_backup_*.tar.gz     （推荐）
#   2) <script_dir>/dev/tools/<tool>_backup_*.tar.gz           （扁平）
find_backup_tool() {
  local tool="$1"
  local base="$SCRIPT_DIR/dev/tools"
  local -a files=()

  if [[ -d "$base/$tool" ]]; then
    shopt -s nullglob
    files=("$base/$tool/${tool}_backup_"*.tar.gz)
    shopt -u nullglob
  fi

  if (( ${#files[@]} == 0 )); then
    shopt -s nullglob
    files=("$base/${tool}_backup_"*.tar.gz)
    shopt -u nullglob
  fi

  (( ${#files[@]} == 0 )) && return 0

  # 按文件名排序（时间戳形式），取最新一个
  printf '%s\n' "${files[@]}" | LC_ALL=C sort | tail -n1
}

# try_restore_tool <pyenv|g|nvm>
#   成功返回 0（表示已恢复，调用方应直接 return 跳过下载）
#   失败返回 1（表示无备份或恢复失败，调用方继续原有在线安装流程）
try_restore_tool() {
  local tool="$1"

  # 允许用户显式禁用本地恢复，强制在线安装
  if [[ "${SKIP_LOCAL_RESTORE:-0}" == "1" ]]; then
    return 1
  fi

  local restore_script="$SCRIPT_DIR/restore.sh"
  if [[ ! -f "$restore_script" ]]; then
    return 1
  fi

  local backup
  backup=$(find_backup_tool "$tool")
  if [[ -z "$backup" ]]; then
    return 1
  fi

  log_info "检测到 $tool 本地备份: $(basename "$backup")，优先执行恢复（跳过在线下载）"
  if bash "$restore_script" "$tool" "$backup"; then
    log_info "$tool 已从本地备份恢复完成"
    return 0
  else
    log_warn "$tool 本地备份恢复失败，将回退到在线安装"
    return 1
  fi
}

# ========== 国内镜像辅助 ==========
# 将 raw.githubusercontent.com/<owner>/<repo>/<ref>/<path>
# 转换为 jsdelivr：https://cdn.jsdelivr.net/gh/<owner>/<repo>@<ref>/<path>
mirror_raw_url() {
  local url="$1"
  case "$url" in
    https://raw.githubusercontent.com/*)
      local rest="${url#https://raw.githubusercontent.com/}"
      local owner="${rest%%/*}"; rest="${rest#*/}"
      local repo="${rest%%/*}";  rest="${rest#*/}"
      local ref="${rest%%/*}";   rest="${rest#*/}"
      printf 'https://fastly.jsdelivr.net/gh/%s/%s@%s/%s' "$owner" "$repo" "$ref" "$rest"
      ;;
    *)
      printf '%s' "$url"
      ;;
  esac
}

# 下载脚本；国内模式对 raw.githubusercontent.com 走 jsdelivr
download_script() {
  local url="$1"
  local out="$2"
  if [[ "$USE_CN_MIRROR" == "1" ]]; then
    url="$(mirror_raw_url "$url")"
  fi
  log_info "下载: $url"
  curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 15 "$url" -o "$out"
}

# 在子进程上下文中注入 git 镜像配置（GIT_CONFIG_* 支持 git >= 2.31）
# 用法: run_with_git_mirror bash install.sh
run_with_git_mirror() {
  if [[ "$USE_CN_MIRROR" == "1" ]]; then
    env \
      GIT_CONFIG_COUNT=1 \
      "GIT_CONFIG_KEY_0=url.${CN_GITHUB_PROXY}https://github.com/.insteadOf" \
      "GIT_CONFIG_VALUE_0=https://github.com/" \
      "$@"
  else
    "$@"
  fi
}

# ========== 依赖检查 ==========
check_dependencies() {
  local deps=("curl" "git")
  for dep in "${deps[@]}"; do
    if ! command -v "$dep" >/dev/null; then
      log_error "必需依赖 '$dep' 未安装，请手动安装后重试"
    fi
  done
  [[ -w "$HOME" ]] || log_error "用户目录 '$HOME' 不可写"
}

# ========== 安装 pyenv（优先恢复本地备份） ==========
install_pyenv() {
  if try_restore_tool pyenv; then
    write_pyenv_config
    apply_pyenv_env
    return 0
  fi

  log_info "安装 Python 版本管理工具 pyenv..."
  local install_script
  install_script=$(mktemp)

  # 官方入口 pyenv.run 会重定向到 raw.githubusercontent.com；
  # 国内模式下直接下载 pyenv-installer 的 raw 文件并由 mirror_raw_url 转换。
  local install_url
  if [[ "$USE_CN_MIRROR" == "1" ]]; then
    install_url="https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer"
  else
    install_url="https://pyenv.run"
  fi

  if ! download_script "$install_url" "$install_script"; then
    rm -f "$install_script"
    log_error "下载 pyenv 安装脚本失败"
  fi

  # 国内源：让 pyenv-installer 内部的 git clone 走镜像
  if ! run_with_git_mirror bash "$install_script"; then
    rm -f "$install_script"
    log_warn "pyenv 安装脚本执行失败（常见于 GitHub 代理不可用）。可尝试：CN_GITHUB_PROXY=https://ghproxy.net/ $0 --cn pyenv"
    log_error "pyenv 安装执行失败"
  fi
  rm -f "$install_script"

  write_pyenv_config
  apply_pyenv_env
}

# ========== 安装 g（优先恢复本地备份） ==========
install_g() {
  if try_restore_tool g; then
    write_g_config
    apply_g_env
    return 0
  fi

  log_info "安装 Go 版本管理工具 g..."
  local install_script
  install_script=$(mktemp)

  local install_url="https://raw.githubusercontent.com/voidint/g/master/install.sh"
  if ! download_script "$install_url" "$install_script"; then
    rm -f "$install_script"
    log_error "下载 g 安装脚本失败"
  fi

  # 国内源：voidint/g 的 install.sh 从 github.com / api.github.com 获取版本并下载
  # release，这里把它们重写为代理前缀。ghfast.top 若不可用，可通过 CN_GITHUB_PROXY 更换。
  if [[ "$USE_CN_MIRROR" == "1" ]]; then
    log_info "重写 g 安装脚本中的 github 地址为镜像: $CN_GITHUB_PROXY"
    local patched
    patched=$(mktemp)
    sed \
      -e "s|https://api.github.com|${CN_GITHUB_PROXY}https://api.github.com|g" \
      -e "s|https://github.com|${CN_GITHUB_PROXY}https://github.com|g" \
      "$install_script" > "$patched"
    mv "$patched" "$install_script"
  fi

  if ! bash "$install_script"; then
    rm -f "$install_script"
    if [[ "$USE_CN_MIRROR" == "1" ]]; then
      log_error "g 安装执行失败，可能是镜像地址不可用。
  请尝试：CN_GITHUB_PROXY=https://ghproxy.net/ $0 --cn g
  或使用官方源：$0 g
  或使用本地备份：$0 g  （确保 restore.sh 与备份文件可用）"
    else
      log_error "g 安装执行失败"
    fi
  fi
  rm -f "$install_script"

  # 说明：官方安装脚本会自行写入 [ -s "$HOME/.g/env" ] && \. "$HOME/.g/env"  # g shell setup
  # 这里再补充显式 GOROOT/PATH 作为兜底，防止 .g/env 未加载时找不到 g
  write_g_config
  apply_g_env
}

# ========== 安装 nvm（优先恢复本地备份） ==========
install_nvm() {
  if try_restore_tool nvm; then
    write_nvm_config
    apply_nvm_env
    return 0
  fi

  log_info "安装 Node 版本管理工具 nvm..."
  local install_script
  install_script=$(mktemp)

  local nvm_version="v0.40.2"
  local install_url="https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh"
  if ! download_script "$install_url" "$install_script"; then
    rm -f "$install_script"
    log_error "下载 nvm 安装脚本失败"
  fi

  # 国内源：nvm install.sh 内部用 git clone 拉取 nvm 仓库，通过 GIT_CONFIG 走镜像
  if ! run_with_git_mirror bash "$install_script"; then
    rm -f "$install_script"
    log_error "nvm 安装执行失败"
  fi
  rm -f "$install_script"

  write_nvm_config
  apply_nvm_env
}

# ========== 安装后刷新 shell 环境（source ~/.bashrc 后再验证） ==========
reload_shell_env() {
  log_info "执行 source \"$HOME/.bashrc\" 以刷新当前环境..."

  # 暂时关闭 -u / -e，避免 .bashrc 中的未定义变量或失败命令打断安装流程
  set +u
  set +e
  # shellcheck disable=SC1090
  source "$HOME/.bashrc" >/dev/null 2>&1
  local rc=$?
  set -e
  set -u

  [[ $rc -ne 0 ]] && log_warn "source ~/.bashrc 返回非零（$rc），继续做兜底加载..."

  # 兜底：部分发行版 ~/.bashrc 开头有 case $- in *i*) ;; *) return;; esac
  # 在非交互脚本中会提前 return，导致上面的 source 实际没有加载任何工具
  if ! command -v pyenv >/dev/null 2>&1 && [[ -d "$HOME/.pyenv/bin" ]]; then
    apply_pyenv_env
  fi

  if ! command -v g >/dev/null 2>&1 && [[ -x "$HOME/.g/bin/g" ]]; then
    apply_g_env
  fi

  if ! command -v nvm >/dev/null 2>&1 && [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    apply_nvm_env
  fi
}

# ========== 验证安装（仅验证本次选中的工具） ==========
verify_installation() {
  log_info "验证安装结果..."

  for tool in "${SELECTED[@]}"; do
    case "$tool" in
      pyenv)
        if ! command -v pyenv >/dev/null; then
          log_error "pyenv 安装验证失败"
        else
          log_info "pyenv 版本: $(pyenv --version)"
        fi
        ;;
      g)
        local g_bin="$HOME/.g/bin/g"
        if ! command -v g >/dev/null 2>&1; then
          log_error "g 安装验证失败（可执行文件应在 $g_bin）"
        fi
        if [[ -x "$g_bin" ]]; then
          log_info "g 版本: $("$g_bin" --version 2>/dev/null || "$g_bin" -v)"
        else
          log_info "g 版本: $(g --version 2>/dev/null || g -v)"
        fi
        ;;
      nvm)
        if ! command -v nvm >/dev/null; then
          log_error "nvm 安装验证失败"
        else
          log_info "nvm 版本: $(nvm --version)"
        fi
        ;;
    esac
  done

  for tool in "${SELECTED[@]}"; do
    case "$tool" in
      pyenv)
        grep -qF "PYENV_ROOT" ~/.bashrc  || log_warn "pyenv 环境变量未正确配置到 ~/.bashrc"
        grep -qF "PYENV_ROOT" ~/.profile || log_warn "pyenv 环境变量未正确配置到 ~/.profile"
        ;;
      g)
        if ! grep -qE '(\.g/bin|GOROOT=.*\.g/go)' ~/.bashrc; then
          log_warn "g 环境变量未正确配置到 ~/.bashrc"
        fi
        if ! grep -qE '(\.g/bin|GOROOT=.*\.g/go)' ~/.profile; then
          log_warn "g 环境变量未正确配置到 ~/.profile"
        fi
        ;;
      nvm)
        grep -qF "NVM_DIR" ~/.bashrc  || log_warn "nvm 环境变量未正确配置到 ~/.bashrc"
        grep -qF "NVM_DIR" ~/.profile || log_warn "nvm 环境变量未正确配置到 ~/.profile"
        ;;
    esac
  done
}

# ========== 参数解析 ==========
SELECTED=()

parse_args() {
  local -a tools_args=()
  local has_tools=0

  for arg in "$@"; do
    case "$arg" in
      --cn|-c)
        USE_CN_MIRROR=1
        ;;
      --no-restore)
        SKIP_LOCAL_RESTORE=1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      all)
        tools_args+=(pyenv g nvm)
        has_tools=1
        ;;
      pyenv|g|nvm)
        tools_args+=("$arg")
        has_tools=1
        ;;
      *)
        log_error "未知参数: $arg（使用 -h 查看帮助）"
        ;;
    esac
  done

  # 不传工具参数则默认安装全部
  if [[ "$has_tools" -eq 0 ]]; then
    tools_args=(pyenv g nvm)
  fi

  # 去重
  local t u skip
  for t in "${tools_args[@]}"; do
    skip=0
    for u in "${SELECTED[@]+"${SELECTED[@]}"}"; do
      if [[ "$u" == "$t" ]]; then
        skip=1
        break
      fi
    done
    if [[ "$skip" -eq 0 ]]; then
      SELECTED+=("$t")
    fi
  done
}

# ========== 选中工具的配置/目录清理（只清理本次将安装的） ==========
clean_selected() {
  for tool in "${SELECTED[@]}"; do
    case "$tool" in
      g)
        rm -rf ~/.g 2>/dev/null || true
        sed -i '/g shell setup/d; /\.g\//d; /GOROOT=.*\.g\/go/d; /G_MIRROR/d' ~/.bashrc 2>/dev/null || true
        sed -i '/g shell setup/d; /\.g\//d; /GOROOT=.*\.g\/go/d; /G_MIRROR/d' ~/.profile 2>/dev/null || true
        ;;
      nvm)
        rm -rf ~/.nvm 2>/dev/null || true
        sed -i '/NVM_DIR/d; /NVM_NODEJS_ORG_MIRROR/d' ~/.bashrc 2>/dev/null || true
        sed -i '/NVM_DIR/d; /NVM_NODEJS_ORG_MIRROR/d' ~/.profile 2>/dev/null || true
        ;;
      pyenv)
        # 与原脚本一致：不主动删除 .pyenv，避免误删用户已有的 Python 版本
        ;;
    esac
  done
}

# ========== 主流程 ==========
main() {
  parse_args "$@"

  if [[ "$USE_CN_MIRROR" == "1" ]]; then
    log_info "已启用国内镜像源模式"
    log_info "  github 代理:  $CN_GITHUB_PROXY"
    log_info "  node 镜像:    $CN_NODE_MIRROR"
    log_info "  go 镜像:      $CN_GO_MIRROR"
    log_info "  python 镜像:  $CN_PYTHON_MIRROR"
  fi

  log_info "清理历史配置（仅针对本次安装的工具）..."
  touch ~/.bashrc ~/.profile
  clean_selected

  check_dependencies

  # 每个 install_* 内部会先尝试本地备份恢复，失败/无备份才在线下载
  for tool in "${SELECTED[@]}"; do
    case "$tool" in
      pyenv) install_pyenv ;;
      g)     install_g ;;
      nvm)   install_nvm ;;
    esac
  done

  # 安装/恢复后先 source ~/.bashrc，再验证
  reload_shell_env

  verify_installation

  echo -e "\n${GREEN}======= 安装成功 =======${NC}"
  echo -e "下一步操作建议:"
  echo -e "1. 重启终端或执行: ${GREEN}source ~/.bashrc${NC}"
  for tool in "${SELECTED[@]}"; do
    case "$tool" in
      pyenv) echo -e "   安装 Python 版本: ${GREEN}pyenv install 3.12.3 && pyenv global 3.12.3${NC}" ;;
      g)     echo -e "   安装 Go 版本:     ${GREEN}g install latest${NC}" ;;
      nvm)   echo -e "   安装 Node 版本:   ${GREEN}nvm install --lts${NC}" ;;
    esac
  done
}

main "$@"