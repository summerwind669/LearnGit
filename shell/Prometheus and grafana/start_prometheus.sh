#!/bin/bash

# 启动 Prometheus，并将日志输出到 prometheus.log
cd ~/prometheus && nohup ./prometheus --config.file=prometheus.yml > prometheus.log 2>&1 &

# 输出 Prometheus 的进程 ID，方便后续停止
echo "Prometheus started with PID: $!"