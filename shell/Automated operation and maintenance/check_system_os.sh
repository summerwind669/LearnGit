#!/bin/bash

# 设置hosts文件路径
hosts_file="/home/ucp/hosts/bj"

# 设置输出文件路径
output_file="/tmp/system_os_check_bj.txt"

# 检查每个分组的欧拉系统升级情况
check_euler_upgrade() {
    group_name=$1
    group_hosts=$(awk -v group="$group_name" '/^\[/{flag=0} /^\['"$group_name"'\]/{flag=1; next} flag' "$hosts_file")
    
    # 检查每个主机
    for host in $group_hosts; do
        # 使用ansible获取系统版本信息，检查是否为 openEuler 20.03
        if ansible -i "$hosts_file" "$host" -m shell -a "cat /etc/os-release | grep 'openEuler 20.03'" &> /dev/null; then
            echo "$host ($group_name) 已升级至 openEuler 20.03" >> "$output_file"
        else
            echo "$host ($group_name) 尚未升级至 openEuler 20.03" >> "$output_file"
        fi
    done
}

# 清空输出文件
> "$output_file"

# 检查并输出每个分组的欧拉系统升级情况
groups=$(awk '/^\[/{gsub(/\[|\]/,""); print}' "$hosts_file")
for group in $groups; do
    echo "分组: $group" >> "$output_file"
    check_euler_upgrade "$group"
    echo "" >> "$output_file"
done

echo "结果已保存到 $output_file"
