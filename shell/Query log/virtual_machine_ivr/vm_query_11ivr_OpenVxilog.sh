#!/bin/bash

#该脚本用户查询虚拟机11ivr的业务OpenVxi.log日志
#实时日志查询格式bash vm_query_11ivr_OpenVxilog.sh 号码
#归档日志查询格式bash vm_query_11ivr_OpenVxilog.sh 号码 2024010415
#时间格式为yyyymmddhh或是yyyymmdd


# 获取变量1（号码）和变量2（时间）
number="$1"
timestamp="$2"

# 使用ansible查询日志
if [ -z "$timestamp" ]; then
    # 如果没有提供时间参数，则执行实时日志查询
    ansible -i ~/hosts/hosts_all 11ivr -m shell -a "zgrep -h '$number' /data/ucp/ipcc/logs/ivr/VPS*/OpenVxi.log"
else
    # 如果提供了时间参数，则执行归档日志查询
    # 检查变量3是否合法（使用正则表达式匹配日期格式）
    if ! [[ $timestamp =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Error: Invalid date format. Use 'yyyy-mm-dd-hh'."
        exit 1
    fi
    ansible -i ~/hosts/hosts_all 11ivr -m shell -a "zgrep -h '$number' /data/ucp/ipcc/ipcc_logs/ivr/VPS*/OpenVxi.log.old.$timestamp*"
fi

