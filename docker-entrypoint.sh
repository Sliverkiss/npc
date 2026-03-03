#!/bin/sh
set -e

echo "⚙️ Container initialization started..."

mkdir -p /app/scripts /app/config /app/shell /var/log/cron

[ ! -f /app/config/cron.list ] && touch /app/config/cron.list

if [ -f /app/shell/task.sh ]; then
    chmod +x /app/shell/task.sh
    ln -sf /app/shell/task.sh /usr/local/bin/task
fi

echo "Initialization complete. Starting cron daemon..."
exec crond -f -l 4
