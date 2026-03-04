#!/bin/bash

# 默认保留最近 7 天日志（你可以传参覆盖）
DAYS=${1:-7}
LOG_DIR="/app/log"

echo "正在清理 $LOG_DIR 中 $DAYS 天前的日志文件..."

# 检查日志目录是否存在
if [ ! -d "$LOG_DIR" ]; then
    echo "错误: 日志目录 $LOG_DIR 不存在"
    exit 1
fi

# 查找并删除指定天数前的 .log 文件
echo "删除 $DAYS 天前的 .log 文件:"
find "$LOG_DIR" -type f -name "*.log" -mtime +$DAYS -exec rm -v {} \;

# 也可以删除其他常见的日志文件格式
echo "删除 $DAYS 天前的其他日志文件:"
find "$LOG_DIR" -type f \( -name "*.log.*" -o -name "*.out" -o -name "*.err" \) -mtime +$DAYS -exec rm -v {} \;

echo "删除空文件夹..."

# 方法1: 使用循环删除嵌套的空文件夹（推荐）
while true; do
    # 查找空文件夹
    empty_dirs=$(find "$LOG_DIR" -mindepth 1 -type d -empty)

    if [ -z "$empty_dirs" ]; then
        echo "没有发现空文件夹"
        break
    fi

    echo "发现空文件夹，正在删除:"
    find "$LOG_DIR" -mindepth 1 -type d -empty -print -delete
done

echo "显示清理后的目录结构:"
if command -v tree >/dev/null 2>&1; then
    tree "$LOG_DIR"
else
    find "$LOG_DIR" -type d | sort
fi

echo "清理完成。"