#!/bin/bash

# 查找 node_exporter 进程的 PID
PID=$(pgrep -f "node_exporter")

# 如果找到了进程，则杀掉它
if [ -z "$PID" ]; then
  echo "node_exporter is not running."
else
  echo "Stopping node_exporter (PID: $PID)..."
  kill $PID
  echo "node_exporter stopped."
fi
