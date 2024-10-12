#!/bin/bash

# 查找 prometheus 进程的 PID
PID=$(pgrep -f "prometheus --config.file=prometheus.yml")

# 如果找到了进程，则杀掉它
if [ -z "$PID" ]; then
  echo "Prometheus is not running."
else
  echo "Stopping Prometheus (PID: $PID)..."
  kill $PID
  echo "Prometheus stopped."
fi
