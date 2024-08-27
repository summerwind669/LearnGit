#!/bin/bash

# 获取当前时间戳
current_time=$(date +"%m-%d %H:%M:%S")

# 计算1分钟前的时间戳
#start_time=$(date -d "-1 minutes" +"%m-%d %H:%M:%S")
start_time=$(date -d "1 minute ago" +"%m-%d %H:%M:%S")

# 定义统计数据的日志文件路径并展开通配符
log_file_pattern="/data/ucp/ipcc/logs/scc/LB/LBUser*.log"
log_files=$(ls $log_file_pattern 2>/dev/null)

# 如果没有匹配到文件，输出错误信息并退出
if [[ -z "$log_files" ]]; then
    echo "Error: No log files found matching pattern $log_file_pattern"
    exit 1
fi

# 检查文件路径
echo "Matched log files:"
echo "$log_files"
echo "---------------------------------"

# 过滤出时间范围内的日志，并分别统计 Evt_ICMU 和 Cmd_ICMU 的出现次数
evt_count=$(awk -v start="$start_time" -v end="$current_time" '$0 ~ /^\[/{if ($0 >= "["start && $0 <= "["end) print}' $log_files | grep -c "Evt_ICMU")
cmd_count=$(awk -v start="$start_time" -v end="$current_time" '$0 ~ /^\[/{if ($0 >= "["start && $0 <= "["end) print}' $log_files | grep -c "Cmd_ICMU")

# 获取当前主机的 IP 地址
ip_address=$(hostname -i)

# 判断 IP 地址前缀判断中心并输出相应的流量数据
if [[ $ip_address == 192.* ]]; then
    echo "通信云洛阳呼入LB一分钟内上行流量为：|$evt_count|int"
    echo "通信云洛阳呼入LB一分钟内下行流量为：|$cmd_count|int"
elif [[ $ip_address == 172.* ]]; then
    echo "通信云淮安呼入LB一分钟内上行流量为：|$evt_count|int"
    echo "通信云淮安呼入LB一分钟内下行流量为：|$cmd_count|int"
else
    echo "无法识别该主机的IP地址：$ip_address"
fi
