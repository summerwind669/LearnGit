#!/bin/bash

# 获取当前时间戳
current_time=$(date +"%m-%d %H:%M:%S")

# 计算1分钟前的时间戳
#start_time=$(date -d "-1 minutes" +"%m-%d %H:%M:%S")
start_time=$(date -d "1 minute ago" +"%m-%d %H:%M:%S")

# 定义统计数据的日志文件路径
log_file="/data/ucp/ipcc/logs/scc/LB/SimpleConn.log"

# 过滤出时间范围内的日志，并分别统计 Evt_IContact 和 Cmd_IContact 的出现次数
evt_count=$(awk -v start="$start_time" -v end="$current_time" '$0 ~ /^\[/{if ($0 >= "["start && $0 <= "["end) print}' $log_file | grep -c "Evt_IContact")
cmd_count=$(awk -v start="$start_time" -v end="$current_time" '$0 ~ /^\[/{if ($0 >= "["start && $0 <= "["end) print}' $log_file | grep -c "Cmd_IContact")

# 获取当前主机的 IP 地址
ip_address=$(hostname -i)

# 判断 IP 地址前缀判断中心并输出相应的流量数据
if [[ $ip_address == 192.* ]]; then
    echo "通信云洛阳在线客服IM LB一分钟内上行流量为：|$evt_count|int"
    echo "通信云洛阳在线客服IM LB一分钟内下行流量为：|$cmd_count|int"
elif [[ $ip_address == 172.* ]]; then
    echo "通信云淮安在线客服IM LB一分钟内上行流量为：|$evt_count|int"
    echo "通信云淮安在线客服IM LB一分钟内下行流量为：|$cmd_count|int"
else
    echo "无法识别该主机的IP地址：$ip_address"
fi
