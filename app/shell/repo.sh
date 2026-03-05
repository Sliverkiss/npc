#!/bin/bash

SCRIPTS_DIR="/app/scripts"
REPO_LIST="/app/config/repo.list"

if [ -z "$1" ]; then
    echo "用法: repo <url>"
    exit 1
fi

URL="$1"

# 获取文件名
FILE_NAME=$(basename "$URL")

# 保存路径
SAVE_PATH="${SCRIPTS_DIR}/${FILE_NAME}"

echo "开始下载脚本:"
echo "$URL"

# 下载脚本
curl -L -s "$URL" -o "$SAVE_PATH"

if [ $? -ne 0 ]; then
    echo "下载失败"
    exit 1
fi

chmod +x "$SAVE_PATH"

echo "下载完成: $SAVE_PATH"

# 如果repo.list不存在就创建
if [ ! -f "$REPO_LIST" ]; then
    touch "$REPO_LIST"
fi

# 判断URL是否已经存在
if grep -q "$URL" "$REPO_LIST"; then
    echo "repo.list 已存在该URL"
else
    echo "${FILE_NAME}|${URL}" >> "$REPO_LIST"
    echo "已加入 repo.list"
fi
