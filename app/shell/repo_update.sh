#!/bin/bash

SCRIPTS_DIR="/app/scripts"
REPO_LIST="/app/config/repo.list"

if [ ! -f "$REPO_LIST" ]; then
    echo "repo.list 不存在，没有可更新的脚本"
    exit 0
fi

echo "开始更新 repo 脚本..."
echo "-----------------------"

while IFS="|" read -r FILE URL
do

    if [ -z "$FILE" ] || [ -z "$URL" ]; then
        continue
    fi

    SAVE_PATH="${SCRIPTS_DIR}/${FILE}"

    echo "更新: $FILE"

    curl -L -s "$URL" -o "$SAVE_PATH"

    if [ $? -eq 0 ]; then
        chmod +x "$SAVE_PATH"
        echo "完成"
    else
        echo "失败"
    fi

    echo "-----------------------"

done < "$REPO_LIST"

echo "全部更新完成"
