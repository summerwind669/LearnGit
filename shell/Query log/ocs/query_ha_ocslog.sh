#!/bin/bash

#该脚本用户查询虚拟机fsm的日志outCallService.log
#实时日志查询格式bash query_ha_ocslog.sh 号码
#归档日志查询格式bash query_ha_ocslog.sh 号码 2024-01-04-16
#归档日志时间格式yyyy-mm-dd-hh

# 获取变量1（号码）和变量2（时间）
number="$1"
timestamp="$2"

# 使用ansible查询日志
if [ -z "$timestamp" ]; then
    # 如果没有提供时间参数，则执行实时日志查询
    ansible -i ~/hosts/hosts_wh ocs_ly -m shell -a "zgrep -h '$number' /home/ucp/outCallService/tomcat*/logs/outCallService*.log"
else
    # 如果提供了时间参数，则执行归档日志查询
    # 检查变量3是否合法（使用正则表达式匹配日期格式）
    if ! [[ $timestamp =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Error: Invalid date format. Use 'yyyy-mm-dd-hh'."
        exit 1
    fi
    ansible -i ~/hosts/hosts_wh ocs_ly -m shell -a "zgrep -h '$number' /home/ucp/outCallService/tomcat*/logs/outCallService*$timestamp*"
fi

