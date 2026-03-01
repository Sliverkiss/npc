#!/bin/bash

#############################################
#       并发任务执行器 v2.0
#       支持无限并发 + 独立执行副本
#############################################

# 加载默认 env
[ -f /app/config/env.sh ] && source /app/config/env.sh

# 参数检测
if [ -z "$1" ]; then
    echo "❗ 请输入要执行的脚本路径，例如："
    echo "   ./task.sh scripts/demo.py"
    exit 1
fi

original_script="$1"

if [ ! -f "$original_script" ]; then
    echo "❌ 文件不存在：$original_script"
    exit 1
fi

# 处理脚本名称信息
script_name=$(basename "$original_script")
script_base="${script_name%.*}"
extension="${script_name##*.}"

# 加载专属 env（可选）
env_file="/app/config/${script_base}.env.sh"
if [ -f "$env_file" ]; then
    echo "📦 加载环境变量文件：$env_file"
    source "$env_file"
fi

# 执行目录
scripts_dir="/app/run"
mkdir -p "$scripts_dir"

# 并发执行关键：为每次执行生成唯一 ID
unique_id="$(date '+%Y-%m-%d-%H-%M-%S')_$$"
run_script="${scripts_dir}/${script_base}_${unique_id}.${extension}"

echo "📄 创建脚本执行副本：$run_script"
cp "$original_script" "$run_script"

# 日志目录与文件
log_folder="/app/log/$script_base"
mkdir -p "$log_folder"
log_file="$log_folder/${unique_id}.log"

echo "📝 本次执行日志：$log_file"

# 执行脚本（按文件类型）
case "$extension" in
  py)
    echo "🎯 执行 Python：$run_script"
    python3 "$run_script" 2>&1 | tee "$log_file"
    ;;
  js)
    echo "🎯 执行 Node：$run_script"
    node "$run_script" 2>&1 | tee "$log_file"
    ;;
  sh)
    echo "🎯 执行 Shell：$run_script"
    bash "$run_script" 2>&1 | tee "$log_file"
    ;;
  *)
    echo "❌ 不支持的脚本类型：.$extension"
    exit 1
    ;;
esac

# 刷新 crontab（兼容青龙逻辑）
if [ -f /app/config/cron.list ]; then
    crontab /app/config/cron.list
else
    echo "⏭ 未找到 /app/config/cron.list，跳过安装 crontab"
fi
