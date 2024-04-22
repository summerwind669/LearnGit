#!/bin/bash

# Define modules with their IP addresses
declare -A modules=(
    ["dm"]="10.119.62.74 10.119.62.75 10.119.62.76 10.119.62.77"
    ["crs"]="10.119.62.78 10.119.62.79 10.137.78.58 10.137.78.59"
    ["flume"]="10.119.62.80 10.137.78.60"
)

# Define color codes
RED='\033[31m'
GREEN='\033[32m'
RESET='\033[0m'

# Function to check performance on a single host
function check_performance() {
    local module="$1"
    local ip="$2"
    local cpu_usage="$3"
    local mem_usage="$4"
    local disk_usage="$5"

    echo "正在检查 $module 模块的 $ip 的CPU、内存、磁盘..."

    # Check CPU usage
    if (( $(echo "$cpu_usage > 50" | bc -l) )); then
        echo -e "${RED}主机 $ip 的 CPU 使用率较高：$cpu_usage%。请注意查看。${RESET}"
    else
        echo -e "${GREEN} $ip CPU利用率正常${RESET}"
    fi

    # Check memory usage
    if (( $(echo "$mem_usage > 80" | bc -l) )); then
        echo -e "${RED}主机 $ip 的内存使用率较高：$mem_usage%。请注意查看。${RESET}"
    else
        echo -e "${GREEN} $ip 内存利用率正常${RESET}"
    fi

    # Check disk usage
    for usage in $disk_usage; do
        usage=${usage%\%}
        if (( $usage > 85 )); then
            echo -e "${RED}主机 $ip 的磁盘使用率较高：$usage%。请清理。${RESET}"
        else
            echo -e "${GREEN} $ip 磁盘利用率正常${RESET}"
        fi
    done
}

# Function to check performance on all hosts for a module
function check_module_performance() {
    local module="$1"
    local ips="${modules[$module]}"
    local cpu_usage="$2"
    local mem_usage="$3"
    local disk_usage="$4"

    # Split IP addresses by space
    IFS=' ' read -ra ip_list <<< "$ips"

    # Connect to each IP address in the current module
    for ip in "${ip_list[@]}"; do
        check_performance "$module" "$ip" "$cpu_usage" "$mem_usage" "$disk_usage"
    done
}

# Main function to check system performance
function check_system_performance() {
    echo "===== 正在执行CPU、内存、磁盘巡检 ====="

    # Get CPU usage
    local cpu_usage=$(top -bn 1 | grep 'Cpu(s)' | awk '{print $2 + $3}' | sed 's/%//')
    cpu_usage=$(echo "scale=2; $cpu_usage / 1" | bc)

    # Get memory usage
    local mem_total=$(free -m | grep 'Mem:' | awk '{print $2}')
    local mem_used=$(free -m | grep 'Mem:' | awk '{print $3}')
    local mem_usage=$(echo "scale=2; $mem_used / $mem_total * 100" | bc)

    # Get disk usage
    local disk_usage=$(df -h | grep '/home\|/data' | awk '{print $5}')

    # Check performance for each module
    for module in "${!modules[@]}"; do
        check_module_performance "$module" "$cpu_usage" "$mem_usage" "$disk_usage"
    done

    # Reset terminal color
    echo -e "${RESET}"
}

# Call main function
check_system_performance
