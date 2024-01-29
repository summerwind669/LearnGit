#!/bin/bash

# 设置日志文件路径和Flume启动脚本路径
LOG_FILE=~/flume_khd/flume/logs/flume.log
START_SCRIPT=~/flume_khd/flume/start-cluster-client.sh

# 函数：检查日志中是否包含OutOfMemory错误
check_out_of_memory() {
    if grep -q "OutOfMemory" "$LOG_FILE"; then
        return 0  # 包含OutOfMemory错误
    else
        return 1  # 不包含OutOfMemory错误
    fi
}

# 函数：重启Flume服务
restart_flume() {
    echo "Detected OutOfMemory error. Restarting Flume..."
    sh "$START_SCRIPT"
}

# 主循环
while true; do
    # 检查日志中是否有OutOfMemory错误
    if check_out_of_memory; then
        restart_flume
    fi

    # 等待一段时间后再次检查
    sleep 300  # 300秒（5分钟）后再次检查
done
