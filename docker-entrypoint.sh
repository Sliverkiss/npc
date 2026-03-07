#!/bin/sh
set -e

echo "Container initialization started..."

# 定义目录
APP_DIR="/app"
CONFIG_DIR="${APP_DIR}/config"
SHELL_DIR="${APP_DIR}/shell"

# 创建必要目录
mkdir -p \
    "${APP_DIR}/scripts" \
    "${CONFIG_DIR}" \
    "${SHELL_DIR}" \
    /var/log/cron

# 修复权限（确保挂载目录可写）
if [ -n "${PUID:-}" ] && [ -n "${PGID:-}" ]; then
    chown -R "${PUID}:${PGID}" "${APP_DIR}"
fi

# 初始化配置文件
[ ! -f "${CONFIG_DIR}/cron.list" ] && touch "${CONFIG_DIR}/cron.list"

# 创建命令软链接函数
link_cmd() {
    name="$1"
    file="${SHELL_DIR}/${name}.sh"

    if [ -f "${file}" ]; then
        chmod +x "${file}"
        ln -sf "${file}" "/usr/local/bin/${name}"
        echo "Linked command: ${name}"
    fi
}

# 自动注册 shell 命令，可扩展
link_cmd task
link_cmd clean

echo "Initialization complete."

# 启动 cron
if ! command -v crond >/dev/null 2>&1; then
    echo "Error: crond not found"
    exit 1
fi

echo "Starting cron daemon..."
exec crond -f -l 4
