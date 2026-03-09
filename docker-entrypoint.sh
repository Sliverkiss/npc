#!/bin/sh
set -e

echo "Container initialization started..."

# 创建所有必要的目录
mkdir -p /app/scripts /app/config /app/shell /var/log/cron

# 如果 /app/config/cron.list 文件不存在，则创建该文件
[ ! -f /app/config/cron.list ] && touch /app/config/cron.list

# 处理 shell 目录中的脚本：设置可执行权限并创建软链接
for script in task clean; do
    script_path="/app/shell/${script}.sh"
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        ln -sf "$script_path" "/usr/local/bin/${script}"
    fi
done

echo "Initialization complete. Starting cron daemon..."
exec crond -f -l 4
