#!/bin/bash

# 定义巡检结果输出目录
output_dir="/home/ucp/shell/znmh_inspect"

# 确保输出目录存在
mkdir -p "$output_dir"

# 执行第一个脚本 check_performance.sh
echo "Executing check_performance.sh..."
./check_performance.sh > "$output_dir/check_performance_result.txt"
echo "check_performance.sh 巡检完成"

# 执行第二个脚本 check_processes_and_ports.sh
echo "Executing check_processes_and_ports.sh..."
./check_processes_and_ports.sh > "$output_dir/check_processes_and_ports_result.txt"
echo "check_processes_and_ports.sh 巡检完成"

# 执行第三个脚本 check_service_logs.sh
echo "Executing check_service_logs.sh..."
./check_service_logs.sh > "$output_dir/check_service_logs_result.txt"
echo "check_service_logs.sh 巡检完成"

echo "所有巡检任务已完成"
