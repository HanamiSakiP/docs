#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# 日志
# ---------------------------------------------------------------------------
log()   { printf '\033[36m[INFO]\033[0m %s\n' "$*"; }
warn()  { printf '\033[33m[WARN]\033[0m %s\n' "$*" >&2; }
error() { printf '\033[31m[ERROR]\033[0m %s\n' "$*" >&2; }
die()   { error "$@"; exit 1; }

# ---------------------------------------------------------------------------
# 常量 / 路径
# ---------------------------------------------------------------------------
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${UNINSTALL_BACKUP_DIR:-$HOME/.toolchain-uninstall-backup.${STAMP}}"

GOPATH="${GOPATH:-$HOME/go}"
PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# restore.sh 写入的多行 g 配置块块头
G_BLOCK_START='# g (Go Version Manager) configuration'

# 单行需要清理的模式（含块被拆散时的兜底）
CONFIG_PATTERNS=(
    'PYENV_ROOT'
    'pyenv init'
    'pyenv virtualenv-init'
    'pyenv/bin'
    'g shell setup'
    '\.g/'
    'NVM_DIR'
    'nvm\.sh'
    'nvm/bash_completion'
    '^# nvm配置'
    '^# nvm$'
    '^# pyenv'
    # 兜底：块头被手工删掉、只剩块内行时的残留
    '^[[:space:]]*unalias[[:space:]]+g[[:space:]]*$'
)
CONFIG_PATTERN="$(IFS='|'; echo "${CONFIG_PATTERNS[*]}")"

# ---------------------------------------------------------------------------
# 临时路径清理
# ---------------------------------------------------------------------------
CLEANUP_PATHS=()
_cleanup_trap() {
    local p
    for p in "${CLEANUP_PATHS[@]+"${CLEANUP_PATHS[@]}"}"; do
        [[ -e "$p" ]] && rm -rf -- "$p"
    done
}
trap _cleanup_trap EXIT

# ---------------------------------------------------------------------------
# 用法
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
用法: ./uninstall.sh [-y|--yes] [-k|--keep-gopath] [-h|--help]

  -y, --yes          跳过确认，直接卸载
  -k, --keep-gopath  保留 GOPATH 目录（默认会删除 ${GOPATH}）
  -h, --help         显示帮助

说明:
  1. 备份并清理 ~/.bashrc 与 ~/.profile 中由 install.sh / restore.sh 写入的配置
     （含 restore.sh 写入的多行 g 配置块）
  2. 删除 ${PYENV_ROOT}、$HOME/.g、${NVM_DIR}（含已安装的语言版本）
  3. 默认删除 GOPATH 目录（${GOPATH}）；使用 -k 可保留
  4. 结束后尝试 source ~/.bashrc 刷新环境

环境变量:
  PYENV_ROOT            pyenv 安装目录（默认: \$HOME/.pyenv）
  NVM_DIR               nvm 安装目录（默认: \$HOME/.nvm）
  GOPATH                Go 工作目录（默认: \$HOME/go）
  UNINSTALL_BACKUP_DIR  卸载前配置备份目录（默认: \$HOME/.toolchain-uninstall-backup.<stamp>）
EOF
}

# ---------------------------------------------------------------------------
# 参数解析
# ---------------------------------------------------------------------------
ASSUME_YES=0
KEEP_GOPATH=0
for arg in "$@"; do
    case "$arg" in
        -y|--yes)         ASSUME_YES=1 ;;
        -k|--keep-gopath) KEEP_GOPATH=1 ;;
        -h|--help)        usage; exit 0 ;;
        *)                die "未知参数: $arg（使用 -h 查看帮助）" ;;
    esac
done

# ---------------------------------------------------------------------------
# 确认
# ---------------------------------------------------------------------------
confirm_uninstall() {
    if [[ $ASSUME_YES -eq 1 ]]; then
        return 0
    fi

    if [[ ! -t 0 || ! -t 1 ]]; then
        die "非交互环境，请使用 -y/--yes 显式确认卸载"
    fi

    echo "即将卸载以下工具链:"
    echo "  - pyenv  : $PYENV_ROOT"
    echo "  - g      : $HOME/.g（含 GOROOT/Go SDK 与已安装的 Go 版本）"
    echo "  - nvm    : $NVM_DIR（含已安装的 Node 版本）"
    if [[ $KEEP_GOPATH -eq 1 ]]; then
        echo "  - GOPATH : 保留（$GOPATH）"
    else
        echo "  - GOPATH : $GOPATH（将被删除，含其中的项目代码与已编译二进制）"
    fi
    echo
    echo "并会备份后清理以下文件中的相关配置:"
    echo "  - $HOME/.bashrc"
    echo "  - $HOME/.profile"
    echo

    local ans=""
    read -r -p "确认继续? [y/N] " ans || ans=""
    case "$ans" in
        y|Y|yes|YES) ;;
        *) warn "已取消卸载"; exit 0 ;;
    esac
}

# ---------------------------------------------------------------------------
# 检测文件中是否含需要清理的配置（含多行 g 块头）
# ---------------------------------------------------------------------------
_file_has_config() {
    local file="$1"
    grep -qF -- "$G_BLOCK_START" "$file" 2>/dev/null && return 0
    grep -qE -- "$CONFIG_PATTERN" "$file" 2>/dev/null && return 0
    return 1
}

# ---------------------------------------------------------------------------
# 清理单个配置文件
# ---------------------------------------------------------------------------
cleanup_config_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        warn "未找到 $file，跳过"
        return 0
    fi

    if ! _file_has_config "$file"; then
        log "$file 无需清理"
        return 0
    fi

    mkdir -p "$BACKUP_DIR"
    local backup="$BACKUP_DIR/$(basename "$file").bak"
    cp -p "$file" "$backup"
    log "已备份 $file -> $backup"

    local tmp1 tmp2 before after
    tmp1="$(mktemp)"; CLEANUP_PATHS+=("$tmp1")
    tmp2="$(mktemp)"; CLEANUP_PATHS+=("$tmp2")
    before=$(wc -l < "$file")

    # 1) 删除 restore.sh 写入的多行 g 配置块
    #    块头: # g (Go Version Manager) configuration
    #    块尾: 含 "g shell setup" 或 ".g/env" 的行（正常情况）
    #    块不完整（缺块尾）时，遇到明显不属于块的行即结束块状态并保留该行，
    #    避免误吞后续内容
    awk '
        /^# g \(Go Version Manager\) configuration/ { in_block = 1; next }
        in_block {
            if ($0 ~ /g shell setup/ || $0 ~ /\.g\/env/) {
                in_block = 0; next
            }
            if ($0 ~ /^[[:space:]]*$/)                                  next
            if ($0 ~ /^[[:space:]]*#/)                                  next
            if ($0 ~ /^[[:space:]]*if[[:space:]]/)                      next
            if ($0 ~ /^[[:space:]]*fi[[:space:]]*$/)                    next
            if ($0 ~ /^[[:space:]]*unalias[[:space:]]+g[[:space:]]*$/)  next
            if ($0 ~ /^[[:space:]]*\[/)                                 next
            if ($0 ~ /GOROOT=.*\.g\/go/)                                next
            in_block = 0
            print
            next
        }
        { print }
    ' "$file" > "$tmp1"

    # 2) 单行模式兜底（pyenv / nvm / 被拆散的 g 块残留等）
    grep -vE -- "$CONFIG_PATTERN" "$tmp1" > "$tmp2" || true

    cat "$tmp2" > "$file"
    after=$(wc -l < "$file")

    log "已清理 $file（$before -> $after 行）"
}

# ---------------------------------------------------------------------------
# 删除工具目录
# ---------------------------------------------------------------------------
remove_pyenv() {
    if [[ -d "$PYENV_ROOT" ]]; then
        log "删除 pyenv: $PYENV_ROOT"
        rm -rf "$PYENV_ROOT" || die "删除 $PYENV_ROOT 失败"
    else
        warn "未发现 $PYENV_ROOT，跳过"
    fi
}

remove_g() {
    if [[ -d "$HOME/.g" ]]; then
        log "删除 g 及 Go SDK/版本: $HOME/.g"
        rm -rf "$HOME/.g" || die "删除 $HOME/.g 失败"
    else
        warn "未发现 $HOME/.g，跳过"
    fi
}

remove_nvm() {
    if [[ -d "$NVM_DIR" ]]; then
        log "删除 nvm 及 Node 版本: $NVM_DIR"
        rm -rf "$NVM_DIR" || die "删除 $NVM_DIR 失败"
    else
        warn "未发现 $NVM_DIR，跳过"
    fi
}

remove_gopath() {
    if [[ $KEEP_GOPATH -eq 1 ]]; then
        log "按参数要求保留 GOPATH: $GOPATH"
        return 0
    fi

    if [[ -z "$GOPATH" || "$GOPATH" == "/" || "$GOPATH" == "$HOME" ]]; then
        die "GOPATH 路径异常（'$GOPATH'），拒绝删除，请检查环境变量 GOPATH"
    fi

    local depth
    depth=$(echo "$GOPATH" | awk -F/ '{print NF-1}')
    if [[ "$depth" -lt 2 ]]; then
        warn "GOPATH 路径 '$GOPATH' 层级较浅，请确认这是期望删除的目录"
    fi

    if [[ -d "$GOPATH" ]]; then
        log "删除 GOPATH: $GOPATH"
        rm -rf "$GOPATH" || die "删除 $GOPATH 失败"
    else
        warn "未发现 $GOPATH，跳过"
    fi
}

# ---------------------------------------------------------------------------
# 残留检查
# ---------------------------------------------------------------------------
post_check() {
    log "检查残留..."

    local found=0 d f
    for d in "$PYENV_ROOT" "$HOME/.g" "$NVM_DIR"; do
        if [[ -e "$d" ]]; then
            warn "残留目录: $d"
            found=1
        fi
    done

    if [[ $KEEP_GOPATH -eq 0 && -e "$GOPATH" ]]; then
        warn "残留目录: $GOPATH"
        found=1
    fi

    for f in "$HOME/.bashrc" "$HOME/.profile"; do
        if [[ -f "$f" ]] && _file_has_config "$f"; then
            warn "残留配置: $f（可手动检查）"
            found=1
        fi
    done

    for f in "$HOME/.bash_profile" "$HOME/.bash_login" "$HOME/.zshrc" "$HOME/.zprofile"; do
        if [[ -f "$f" ]] && _file_has_config "$f"; then
            warn "$f 中仍有相关配置，脚本未修改该文件，请按需手动清理"
            found=1
        fi
    done

    if [[ $found -eq 0 ]]; then
        log "未发现残留"
    fi
}

# ---------------------------------------------------------------------------
# 刷新 shell 环境
# ---------------------------------------------------------------------------
reload_shell_env() {
    local rc="$HOME/.bashrc"
    [[ -f "$rc" ]] || { warn "未找到 $rc，跳过环境刷新"; return 0; }

    log "尝试 source \"$rc\" 以刷新当前脚本环境..."
    set +u; set +e
    # shellcheck disable=SC1090
    source "$rc" >/dev/null 2>&1
    local rc_code=$?
    set -e; set -u
    if [[ $rc_code -ne 0 ]]; then
        warn "source $rc 返回非零（$rc_code），不影响卸载结果，请手动检查该文件"
    fi
}

print_final_hint() {
    echo
    echo "注意: 脚本内的 source 只作用于脚本自身进程，不会改变你当前交互式 shell 的环境。"
    echo "请在你的当前终端执行以下命令之一，使配置生效:"
    echo "    source ~/.bashrc"
    echo "    exec bash"
    echo "或者直接重开一个终端。"
}

# ---------------------------------------------------------------------------
# 主流程
# ---------------------------------------------------------------------------
main() {
    confirm_uninstall

    log "开始清理 shell 配置..."
    cleanup_config_file "$HOME/.bashrc"
    cleanup_config_file "$HOME/.profile"

    log "开始删除工具目录..."
    remove_pyenv
    remove_g
    remove_nvm
    remove_gopath

    post_check

    echo
    log "======= 卸载完成 ======="
    if [[ -d "$BACKUP_DIR" ]]; then
        echo "配置备份目录: $BACKUP_DIR"
        echo "如需回滚，可执行:"
        echo "    cp -p $BACKUP_DIR/.bashrc.bak ~/.bashrc"
        echo "    cp -p $BACKUP_DIR/.profile.bak ~/.profile"
    fi

    reload_shell_env
    print_final_hint
}

main "$@"