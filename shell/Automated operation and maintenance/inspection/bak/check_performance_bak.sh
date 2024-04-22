#!/bin/bash

# 定义主机列表
hosts=("10.119.62.78" "10.119.62.78")

# Define function
function check_system_performance() {
  local has_issues=false
  
  for host in "${hosts[@]}"; do
    # Get CPU usage
    cpu_usage=$(ssh -q $host top -bn 1 | grep 'Cpu(s)' | awk '{print $2 + $3}' | sed 's/%//')
    cpu_usage=$(echo "scale=2; $cpu_usage / 1" | bc)

    # Check CPU usage
    if (( $(echo "$cpu_usage > 50" | bc -l) )); then
      echo -e "${YELLOW}主机 $host 的 CPU 使用率较高：$cpu_usage%。请注意查看。${RESET}"
      has_issues=true
    fi

    # Get memory usage
    mem_total=$(ssh -q $host free -m | grep 'Mem:' | awk '{print $2}')
    mem_used=$(ssh -q $host free -m | grep 'Mem:' | awk '{print $3}')
    mem_usage=$(echo "scale=2; $mem_used / $mem_total * 100" | bc)

    # Check memory usage
    if (( $(echo "$mem_usage > 80" | bc -l) )); then
      echo -e "${RED}主机 $host 的内存使用率较高：$mem_usage%。请注意查看。${RESET}"
      has_issues=true
    fi

    # Get disk usage
    disk_usage=$(ssh -q $host df -h | grep '/home\|/data' | awk '{print $5}')

    # Check disk usage
    for usage in $disk_usage; do
      usage=${usage%\%}
      if (( $usage > 85 )); then
        echo -e "${RED}主机 $host 的磁盘使用率较高：$usage%。请清理。${RESET}"
        has_issues=true
      fi
    done
  done

  # Output if everything is fine
  if ! $has_issues; then
    echo "系统性能正常，没有发现异常。"
  fi
}

# Define color codes
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# Call function
check_system_performance
