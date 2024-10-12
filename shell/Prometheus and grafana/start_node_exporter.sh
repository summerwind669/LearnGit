#!/bin/bash

# 启动 node_exporter，并将日志输出到 node_exporter.log
cd ~/node_exporter && nohup ./node_exporter > node_exporter.log 2>&1 &

# 输出 node_exporter 的进程 ID，方便后续停止
echo "node_exporter started with PID: $!"