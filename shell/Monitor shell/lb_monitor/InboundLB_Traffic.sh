#!/bin/bash

# 获取当前时间戳
current_time=$(date +"%m-%d %H:%M:%S")

# 计算五分钟前的时间戳
start_time=$(date -d "-5 minutes" +"%m-%d %H:%M:%S")

# 获取日志文件路径
log_file="/data/ucp/ipcc/logs/scc/LB/LBUser.log"

# 使用 grep 和 awk 过滤出时间范围内的日志，并分别统计 Evt_ICMU 和 Cmd_ICMU 的出现次数
evt_count=$(grep -E "^\[$start_time.*$|^\[$current_time.*$" "$log_file" | grep -c "Evt_ICMU")
cmd_count=$(grep -E "^\[$start_time.*$|^\[$current_time.*$" "$log_file" | grep -c "Cmd_ICMU")

# 获取当前主机的 IP 地址
ip_address=$(hostname -i)

# 判断 IP 地址前缀并输出相应的信息
if [[ $ip_address == 192.* ]]; then
    echo "洛阳呼入LB五分钟内上行流量为：$evt_count"
elif [[ $ip_address == 172.* ]]; then
    echo "淮安呼入LB五分钟内下行流量为：$cmd_count"
else
    echo "无法识别该主机的IP地址：$ip_address"
fi
