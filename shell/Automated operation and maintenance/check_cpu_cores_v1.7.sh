#!/bin/bash

# 设置hosts文件路径
hosts_file="/home/ucp/hosts/hosts_all"

# 设置输出文件路径
output_file="/tmp/cpu_cores_summary.txt"

# 检查每个分组的CPU核心数
check_cpu_cores() {
    group_name=$1
    group_hosts=$(awk -v group="$group_name" '/^\[/{flag=0} /^\['"$group_name"'\]/{flag=1; next} flag' "$hosts_file")
    total_cores_x86=0
    total_cores_arm=0

    # 检查每个主机
    for host in $group_hosts; do
        # 使用ansible获取CPU核心数
        cores=$(ansible -i "$hosts_file" "$host" -m shell -a "lscpu | grep -w 'CPU(s):' | grep -v node" | grep -v SUCCESS | awk '{print $NF}')
        cores=$(echo "$cores" | tr -d '\r')  # 去除可能的回车符
        if [ -n "$cores" ]; then
            if ansible -i "$hosts_file" "$host" -m shell -a "uname -r | grep -q 'x86'"; then
                total_cores_x86=$(awk "BEGIN {print $total_cores_x86 + $cores}")
            elif ansible -i "$hosts_file" "$host" -m shell -a "uname -r | grep -q 'aarch'"; then
                total_cores_arm=$(awk "BEGIN {print $total_cores_arm + $cores}")
            fi
        fi
    done

    if [ $total_cores_x86 -gt 0 ]; then
        echo "$group_name x86 group: $total_cores_x86 CPU cores" >> "$output_file"
    fi

    if [ $total_cores_arm -gt 0 ]; then
        echo "$group_name ARM group: $total_cores_arm CPU cores" >> "$output_file"
    fi
}

# 清空输出文件
> "$output_file"

# 检查并输出每个分组的CPU核心数
groups=$(awk '/^\[/{gsub(/\[|\]/,""); print}' "$hosts_file")
for group in $groups; do
    check_cpu_cores "$group"
done

echo "结果已保存到 $output_file"
