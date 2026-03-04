#!/bin/sh
set -e

echo "Container initialization started..."

# 创建所有必要的目录
mkdir -p /app/scripts /app/config /app/shell /var/log/cron
mkdir -p /root/.config/code-server

# 初始化 /app：将镜像内模板补齐到挂载目录（不覆盖已有文件）
if [ -d /opt/app-template ]; then
    cp -an /opt/app-template/. /app/
fi

[ ! -f /app/config/env.sh ] && touch /app/config/env.sh
[ ! -f /app/config/cron.list ] && touch /app/config/cron.list

CODE_SERVER_CONFIG_FILE="/root/.config/code-server/config.yaml"

# 初始化 code-server 配置文件
if [ ! -f "${CODE_SERVER_CONFIG_FILE}" ]; then
    cat > "${CODE_SERVER_CONFIG_FILE}" <<EOF
bind-addr: 127.0.0.1:8080
auth: password
cert: false
EOF
fi

escape_sed_replacement() {
    printf '%s' "$1" | sed 's/[\/&]/\\&/g'
}

set_yaml_key() {
    key="$1"
    value="$2"
    escaped_value="$(escape_sed_replacement "${value}")"
    if grep -q "^${key}:" "${CODE_SERVER_CONFIG_FILE}"; then
        sed -i "s/^${key}:.*/${key}: ${escaped_value}/" "${CODE_SERVER_CONFIG_FILE}"
    else
        printf '%s: %s\n' "${key}" "${value}" >> "${CODE_SERVER_CONFIG_FILE}"
    fi
}

# 支持通过 CODE_SERVER_PASSWORD 自定义 code-server 密码
if [ -n "${CODE_SERVER_PASSWORD:-}" ]; then
    set_yaml_key "auth" "password"
    set_yaml_key "password" "${CODE_SERVER_PASSWORD}"
    set_yaml_key "cert" "false"
    echo "code-server password configured from environment variable."
fi

# 判断 /app/shell/task.sh 是否存在，如果存在，则设置可执行权限并创建软链接到 /usr/local/bin/task
if [ -f /app/shell/task.sh ]; then
    chmod +x /app/shell/task.sh
    ln -sf /app/shell/task.sh /usr/local/bin/task
fi

if [ -f /app/shell/clean.sh ]; then
    chmod +x /app/shell/clean.sh
    ln -sf /app/shell/clean.sh /usr/local/bin/clean
fi

echo "Initialization complete. Starting cron daemon..."
if ! command -v cron > /dev/null 2>&1; then
    echo "cron daemon not found."
    exit 1
fi
cron

echo "Starting code-server..."
exec code-server --bind-addr 0.0.0.0:8080 /app
