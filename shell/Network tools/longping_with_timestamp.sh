#!/bin/bash

# 目标主机 IP 或主机名
TARGET="B_HOST_IP_OR_NAME"

# 输出文件路径
OUTPUT_FILE="ping_result.log"

# 开始 ping 目标主机
while true
do
    # 获取当前时间
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

    # 执行 ping 并获取结果
    PING_RESULT=$(ping -c 1 $TARGET)

    # 将时间戳和 ping 结果写入输出文件
    echo "[$TIMESTAMP] $PING_RESULT" >> $OUTPUT_FILE

    # 添加一个延迟，避免频繁 ping（例如：每 1 秒 ping 一次）
    sleep 1
done
