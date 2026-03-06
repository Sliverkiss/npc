#!/bin/bash

# 加载全局环境变量（可选）
[ -f /app/config/env.sh ] && source /app/config/env.sh

if [ -z "$1" ]; then
    echo "❗ 请输入要执行的脚本路径，例如："
    echo "   task ./demo.py"
    exit 1
fi

# ===============================
# task status
# ===============================
if [ "$1" = "status" ]; then
    count=$(ps -eo cmd | grep "/app/run/" | grep -E "node|python" | grep -v grep | wc -l)

    echo "📊 Task 状态"
    echo "----------------------------------"
    printf "%-20s %s\n" "运行脚本数量" "$count"
    echo "----------------------------------"
    exit 0
fi


# ===============================
# task stopall
# ===============================
if [ "$1" = "stopall" ]; then
    echo "🛑 正在停止所有运行中的脚本..."
    echo "----------------------------------"

    pids=$(grep -l "/app/run/" /proc/*/cmdline 2>/dev/null | awk -F'/' '{print $3}')

    if [ -z "$pids" ]; then
        echo "✔ 没有正在运行的脚本"
        exit 0
    fi

    for pid in $pids; do
        printf "%-10s %s\n" "停止PID" "$pid"
        kill "$pid" 2>/dev/null
    done

    echo "----------------------------------"
    echo "✅ 全部脚本已停止"
    exit 0
fi


# ===============================
# task top
# ===============================
if [ "$1" = "top" ]; then

while true
do
    clear

    echo "📊 Task 实时监控  $(date '+%Y-%m-%d %H:%M:%S')"
    echo "按 Ctrl+C 退出"
    echo "---------------------------------------------------------------------"
    printf "%-8s %-12s %-s\n" "PID" "运行时间" "脚本"
    echo "---------------------------------------------------------------------"

    for pid in /proc/[0-9]*; do
        pid=${pid#/proc/}

        cmdline="/proc/$pid/cmdline"

        if [ -f "$cmdline" ]; then
            cmd=$(tr '\0' ' ' < "$cmdline")

            if echo "$cmd" | grep -q "/app/run/"; then

                start=$(stat -c %Y /proc/$pid 2>/dev/null)
                now=$(date +%s)

                runtime=$((now - start))

                # 时间格式化
                h=$((runtime/3600))
                m=$((runtime%3600/60))
                s=$((runtime%60))

                if [ $h -gt 0 ]; then
                    runtime="${h}h${m}m${s}s"
                elif [ $m -gt 0 ]; then
                    runtime="${m}m${s}s"
                else
                    runtime="${s}s"
                fi

                printf "%-8s %-12s %-s\n" "$pid" "$runtime" "$cmd"
            fi
        fi
    done

    echo "---------------------------------------------------------------------"

    sleep 1
done

fi

original_script="$1"

if [ ! -f "$original_script" ]; then
    echo "文件不存在：$original_script"
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

scripts_dir="/app/run"
target_script="$scripts_dir/$script_name"

mkdir -p "$scripts_dir"

if [ -f "$target_script" ]; then
    src_md5=$(md5sum "$original_script" | awk '{print $1}')
    dst_md5=$(md5sum "$target_script" | awk '{print $1}')

    if [ "$src_md5" == "$dst_md5" ]; then
        echo "脚本未发生变化，跳过覆盖：$target_script"
    else
        echo "脚本已更新，覆盖原文件：$target_script"
        cp -f "$original_script" "$target_script"
    fi
else
    echo "脚本不存在，首次复制到：$target_script"
    cp "$original_script" "$target_script"
fi

log_folder="/app/log/$script_base"
mkdir -p "$log_folder"
log_file="$log_folder/$(date '+%Y-%m-%d-%H-%M-%S').log"

case "$extension" in
  py)
    echo "执行 Python 脚本: $target_script"
    python3 "$target_script" 2>&1 | tee "$log_file"
    ;;
  js)
    echo "执行 Node.js 脚本: $target_script"
    node "$target_script" 2>&1 | tee "$log_file"
    ;;
  *)
    echo "不支持的脚本类型: .$extension"
    exit 1
    ;;
esac

if [ -f /app/config/cron.list ]; then
    echo "⏰ 刷新cron定时任务列表成功！"
    crontab /app/config/cron.list
else
    echo "未找到 /app/config/cron.list，跳过安装 crontab"
fi
