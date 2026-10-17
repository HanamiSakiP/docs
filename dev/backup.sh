#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${BACKUP_OUTPUT_DIR:-$SCRIPT_DIR/dev/tools}"
STAMP="$(date +%Y%m%d%H%M%S)"
SKIP_MISSING=0

# 通用排除模式（tar 参数形式）
EXCLUDES=(
    '--exclude=.git'
    '--exclude=.github'
    '--exclude=.gitignore'
    '--exclude=.gitmodules'
    '--exclude=.gitattributes'
    '--exclude=.cache'
    '--exclude=test'
    '--exclude=tests'
    '--exclude=docs'
    '--exclude=man'
    '--exclude=*.md'
    '--exclude=LICENSE'
    '--exclude=LICENSE.*'
    '--exclude=Makefile'
    '--exclude=Dockerfile'
    '--exclude=*.png'
    '--exclude=*.gif'
    '--exclude=*.jpg'
    '--exclude=*.jpeg'
    '--exclude=*.svg'
    '--exclude=*.ico'
    '--exclude=*.pyc'
    '--exclude=__pycache__'
    '--exclude=*.pyo'
    '--exclude=*.log'
    '--exclude=tmp'
    '--exclude=temp'
    '--exclude=rename_test.sh'
    '--exclude=update_test_mocks.sh'
    '--exclude=install.sh'
    '--exclude=package.json'
    '--exclude=package-lock.json'
)

log()   { printf '\033[36m[INFO]\033[0m %s\n' "$*"; }
warn()  { printf '\033[33m[WARN]\033[0m %s\n' "$*" >&2; }
error() { printf '\033[31m[ERROR]\033[0m %s\n' "$*" >&2; }

# ---------------------------------------------------------------------------
# tar 选项能力检测（实测，避免 --help 误判）
# ---------------------------------------------------------------------------
TAR_WARN_OPTS=()
if tar --warning=no-file-changed -cf /dev/null /dev/null >/dev/null 2>&1; then
    TAR_WARN_OPTS=(--warning=no-file-changed)
else
    warn "当前 tar 不支持 --warning=no-file-changed，将容忍 rc=1 警告输出。"
fi

TAR_EXTRA_OPTS=()
if tar --ignore-failed-read -cf /dev/null /dev/null >/dev/null 2>&1; then
    TAR_EXTRA_OPTS=(--ignore-failed-read)
else
    warn "当前 tar 不支持 --ignore-failed-read，遇到 ELOOP 等读错误会中断该工具备份。"
fi

# ---------------------------------------------------------------------------
# 磁盘空间轻量检查（不阻断，仅 WARN）
# ---------------------------------------------------------------------------
check_disk() {
    local avail_kb
    avail_kb=$(df -Pk "$OUTPUT_DIR" 2>/dev/null | awk 'NR==2 {print $4}')
    if [ -n "$avail_kb" ] && [ "$avail_kb" -lt 204800 ]; then
        warn "输出目录 $OUTPUT_DIR 剩余空间较小（${avail_kb}KB），备份可能失败。"
    fi
}

usage() {
    cat <<'EOF'
用法:
  backup.sh [g] [nvm] [pyenv] [all]

不传参数时默认备份全部已安装工具: g / nvm / pyenv。
指定 all 也会备份全部，并跳过未安装的工具。
指定具体工具时，如果该工具不存在则报错退出。

环境变量:
  BACKUP_OUTPUT_DIR  备份输出目录，默认 <script_dir>/dev/tools
                     （与 restore.sh 的自动模式默认路径一致）
  PYENV_ROOT         pyenv 根目录，默认 $HOME/.pyenv
  GOPATH             Go 工作目录，默认 $HOME/go；若 /go 存在也会一并打包

示例:
  ./backup.sh
  ./backup.sh g nvm
  ./backup.sh pyenv
  BACKUP_OUTPUT_DIR=~/backups ./backup.sh all

配合 restore.sh:
  默认输出到 <script_dir>/dev/tools，直接运行 ./restore.sh 即可自动恢复
  未安装的工具。若使用 BACKUP_OUTPUT_DIR 指定其他目录，请把备份放到
  restore.sh 的 BACKUP_BASE（默认 <script_dir>/dev/tools）下，或使用
  ./restore.sh <dir> 指定目录。
EOF
}

# ---------------------------------------------------------------------------
# g / go 备份
# ---------------------------------------------------------------------------
backup_g() {
    local tool_name="g"
    local out="$OUTPUT_DIR/${tool_name}_backup_${STAMP}.tar.gz"
    local tmp pack_stage
    local found=0
    local packed_paths=()

    tmp="$(mktemp -d)"
    pack_stage="$(mktemp -d)"
    trap 'rm -rf -- "$tmp" "$pack_stage"' EXIT

    # pack_dir <源目录> <归档内目标路径> [strict]
    #   strict=1（默认）：失败返回非零
    #   strict=0        ：失败仅警告并跳过
    # 两步式：先 tar 到 pack_stage 临时文件，再解压到 tmp。
    # 避免 `tar -cf - | tar -xf -` 在 pipefail 下退出码语义混乱。
    pack_dir() {
        local src="$1"
        local dst="$2"
        local strict="${3:-1}"
        [ -d "$src" ] || return 0

        local abs
        abs="$(cd "$src" && pwd)"

        local p
        for p in "${packed_paths[@]+"${packed_paths[@]}"}"; do
            [ "$p" = "$abs" ] && return 0
        done

        mkdir -p "$tmp/$dst"

        local tarfile
        tarfile="$(mktemp "$pack_stage/pack.XXXXXX.tar")" || {
            if [ "$strict" -eq 1 ]; then
                error "无法创建临时 tar 文件"
                return 1
            fi
            warn "无法创建临时 tar 文件，跳过 $src"
            return 0
        }

        local crc=0
        ( cd "$src" && tar \
            "${TAR_WARN_OPTS[@]+"${TAR_WARN_OPTS[@]}"}" \
            "${TAR_EXTRA_OPTS[@]+"${TAR_EXTRA_OPTS[@]}"}" \
            "${EXCLUDES[@]}" -cf "$tarfile" . ) || crc=$?

        if [ "$crc" -gt 1 ]; then
            rm -f -- "$tarfile"
            rm -rf -- "${tmp:?}/$dst"
            if [ "$strict" -eq 1 ]; then
                error "tar 打包 $src 失败（rc=$crc）"
                return 1
            fi
            warn "tar 打包 $src 失败（rc=$crc），已跳过"
            return 0
        fi
        if [ "$crc" -eq 1 ]; then
            warn "打包 $src 时部分文件读取过程中发生变化（已容忍）"
        fi

        local xrc=0
        ( cd "$tmp/$dst" && tar -xpf "$tarfile" ) || xrc=$?
        rm -f -- "$tarfile"

        if [ "$xrc" -ne 0 ]; then
            rm -rf -- "${tmp:?}/$dst"
            if [ "$strict" -eq 1 ]; then
                error "解压 $src 到临时区失败（rc=$xrc）"
                return 1
            fi
            warn "解压 $src 到临时区失败（rc=$xrc），已跳过"
            return 0
        fi

        packed_paths+=("$abs")
        found=1
        return 0
    }

    check_disk

    # 原有 g 相关目录（保留相对结构，便于恢复）
    pack_dir "$HOME/.${tool_name}" ".${tool_name}" \
        || { error "打包 $HOME/.${tool_name} 失败"; return 1; }
    pack_dir "$HOME/.goenv" ".goenv" \
        || { error "打包 $HOME/.goenv 失败"; return 1; }
    pack_dir "$HOME/.config/${tool_name}" ".config/${tool_name}" \
        || { error "打包 $HOME/.config/${tool_name} 失败"; return 1; }

    # GOPATH（install.sh 默认 $HOME/go；容器中常为 /go）
    local gopath="${GOPATH:-$HOME/go}"
    if [ -d "$gopath" ]; then
        local gopath_arc
        case "$gopath" in
            "$HOME"/*) gopath_arc="${gopath#"$HOME"/}" ;;
            "/go")     gopath_arc="_go" ;;
            *)         gopath_arc="_abs$(printf '%s' "$gopath" | tr '/' '_')" ;;
        esac
        pack_dir "$gopath" "$gopath_arc" \
            || { error "打包 GOPATH($gopath) 失败"; return 1; }
    fi

    # /go 目录（当 GOPATH 不是 /go 时单独打包；失败仅警告）
    if [ -d "/go" ]; then
        pack_dir "/go" "_go" 0
    fi

    if [ "$found" -eq 0 ]; then
        if [ "$SKIP_MISSING" -eq 1 ]; then
            warn "未找到 g/go 相关目录，跳过 g 备份。"
            return 0
        fi
        error "未找到 g/go 相关目录（\$HOME/.g、\$GOPATH、/go 等均不存在）"
        return 1
    fi

    grep -E "(PATH.*\.${tool_name}/bin|GOROOT|GOPATH|/go/bin)" \
        "$HOME"/.{bashrc,zshrc,profile} 2>/dev/null \
        > "$tmp/env_config" || true

    {
        echo "ARCH=$(uname -m)"
        echo "OS=$(uname -s)"
        echo "GOPATH=$gopath"
    } > "$tmp/platform_info"

    tar -czf "$out" -C "$tmp" .
    rm -rf -- "$tmp" "$pack_stage"
    trap - EXIT

    log "备份已创建: $out"
    log "注意: g/go 版本依赖平台，平台信息已保存在归档内的 ./platform_info"
}

# ---------------------------------------------------------------------------
# nvm 备份
# ---------------------------------------------------------------------------
backup_nvm() {
    local out="$OUTPUT_DIR/nvm_backup_${STAMP}.tar.gz"

    if [ ! -d "$HOME/.nvm" ]; then
        if [ "$SKIP_MISSING" -eq 1 ]; then
            warn "$HOME/.nvm 不存在，跳过 nvm 备份。"
            return 0
        fi
        error ".nvm 目录不存在: $HOME/.nvm"
        return 1
    fi

    check_disk

    # nvm 专用排除：去掉 package.json / package-lock.json。
    # npm 自身位于 .nvm/versions/node/<ver>/lib/node_modules/npm/，
    # 其内部 package.json 是 npm 运行必需文件，不能排除。
    local nvm_excludes=()
    local ex
    for ex in "${EXCLUDES[@]}"; do
        case "$ex" in
            --exclude=package.json|--exclude=package-lock.json) continue ;;
            *) nvm_excludes+=("$ex") ;;
        esac
    done

    local rc=0
    tar "${TAR_WARN_OPTS[@]+"${TAR_WARN_OPTS[@]}"}" \
        "${TAR_EXTRA_OPTS[@]+"${TAR_EXTRA_OPTS[@]}"}" \
        "${nvm_excludes[@]}" \
        -czf "$out" -C "$HOME" .nvm || rc=$?

    if [ "$rc" -gt 1 ]; then
        rm -f -- "$out"
        error "打包 $HOME/.nvm 失败（tar rc=$rc，详见上方 tar 输出）"
        return 1
    fi
    if [ "$rc" -eq 1 ]; then
        warn "nvm 备份过程中部分文件被跳过或发生变化（已容忍，归档可用）"
    fi

    log "备份已创建: $out"
}

# ---------------------------------------------------------------------------
# pyenv 备份
# ---------------------------------------------------------------------------
backup_pyenv() {
    local pyenv_root
    local pyenv_parent
    local pyenv_base
    local out

    pyenv_root="${PYENV_ROOT:-$HOME/.pyenv}"
    out="$OUTPUT_DIR/pyenv_backup_${STAMP}.tar.gz"

    if [ ! -d "$pyenv_root" ]; then
        if [ "$SKIP_MISSING" -eq 1 ]; then
            warn "pyenv 根目录不存在: $pyenv_root，跳过 pyenv 备份。"
            return 0
        fi
        error "pyenv 根目录不存在: $pyenv_root"
        return 1
    fi

    check_disk

    pyenv_root="$(cd "$pyenv_root" && pwd)"
    pyenv_parent="$(dirname "$pyenv_root")"
    pyenv_base="$(basename "$pyenv_root")"

    local rc=0
    tar "${TAR_WARN_OPTS[@]+"${TAR_WARN_OPTS[@]}"}" \
        "${TAR_EXTRA_OPTS[@]+"${TAR_EXTRA_OPTS[@]}"}" \
        "${EXCLUDES[@]}" \
        -czf "$out" -C "$pyenv_parent" "$pyenv_base" || rc=$?

    if [ "$rc" -gt 1 ]; then
        rm -f -- "$out"
        error "打包 pyenv($pyenv_root) 失败（tar rc=$rc，详见上方 tar 输出）"
        return 1
    fi
    if [ "$rc" -eq 1 ]; then
        warn "pyenv 备份过程中部分文件被跳过或发生变化（已容忍，归档可用）"
    fi

    log "备份已创建: $out"
}

# ---------------------------------------------------------------------------
# 参数解析
# ---------------------------------------------------------------------------
if [ "$#" -eq 0 ]; then
    SELECTED=(g nvm pyenv)
    SKIP_MISSING=1
else
    SELECTED=()
    for arg in "$@"; do
        case "$arg" in
            all)
                SELECTED+=(g nvm pyenv)
                SKIP_MISSING=1
                ;;
            g|nvm|pyenv)
                SELECTED+=("$arg")
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                error "未知参数: $arg"
                usage
                exit 1
                ;;
        esac
    done
fi

# 去重
UNIQUE=()
for t in "${SELECTED[@]}"; do
    skip=0
    for u in "${UNIQUE[@]}"; do
        if [ "$u" = "$t" ]; then
            skip=1
            break
        fi
    done
    if [ "$skip" -eq 0 ]; then
        UNIQUE+=("$t")
    fi
done
SELECTED=("${UNIQUE[@]}")

if [ "${#SELECTED[@]}" -eq 0 ]; then
    usage
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

log "=== 备份开始 ==="
log "输出目录: $OUTPUT_DIR"

# 每个工具在子 shell 中执行：函数内 set -e 保持生效，
# 一个工具失败也不会终止主循环，最后汇总失败工具。
FAILED_TOOLS=()
for tool in "${SELECTED[@]}"; do
    rc=0
    case "$tool" in
        g)     ( backup_g )     || rc=$? ;;
        nvm)   ( backup_nvm )   || rc=$? ;;
        pyenv) ( backup_pyenv ) || rc=$? ;;
    esac
    if [ "$rc" -ne 0 ]; then
        error "$tool 备份失败（rc=$rc），继续处理其他工具。"
        FAILED_TOOLS+=("$tool")
    fi
done

log "备份输出目录: $OUTPUT_DIR"
if [ "${#FAILED_TOOLS[@]}" -gt 0 ]; then
    error "以下工具备份失败: ${FAILED_TOOLS[*]}"
    exit 1
fi
log "=== 全部选定备份已完成 ==="