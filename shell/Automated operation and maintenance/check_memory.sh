#!/bin/bash

# 设置hosts文件路径
hosts_file="/home/ucp/hosts/hosts_all"

# 设置输出文件路径
output_file="/tmp/memory_summary.txt"

# 检查每个分组的内存大小
check_memory_size() {
    group_name=$1
    group_hosts=$(awk -v group="$group_name" '/^\[/{flag=0} /^\['"$group_name"'\]/{flag=1; next} flag' "$hosts_file")
    total_memory_x86=0
    total_memory_arm=0

    # 检查每个主机
    for host in $group_hosts; do
        # 使用ansible获取内存大小
        memory=$(ansible -i "$hosts_file" "$host" -m shell -a "free -g | grep 'Mem:' | awk '{print \$2}'" | grep -v SUCCESS)
        memory=$(echo "$memory" | tr -d '\r')  # 去除可能的回车符
        if [ -n "$memory" ]; then
            if ansible -i "$hosts_file" "$host" -m shell -a "uname -m | grep -q 'x86'"; then
                total_memory_x86=$(awk "BEGIN {print $total_memory_x86 + $memory}")
            elif ansible -i "$hosts_file" "$host" -m shell -a "uname -m | grep -q 'aarch'"; then
                total_memory_arm=$(awk "BEGIN {print $total_memory_arm + $memory}")
            fi
        fi
    done

    if [ $total_memory_x86 -gt 0 ]; then
        echo "$group_name x86 group: $total_memory_x86 GB memory" >> "$output_file"
    fi

    if [ $total_memory_arm -gt 0 ]; then
        echo "$group_name ARM group: $total_memory_arm GB memory" >> "$output_file"
    fi
}

# 清空输出文件
> "$output_file"

# 检查并输出每个分组的内存大小
groups=$(awk '/^\[/{gsub(/\[|\]/,""); print}' "$hosts_file")
for group in $groups; do
    check_memory_size "$group"
done

echo "结果已保存到 $output_file"
