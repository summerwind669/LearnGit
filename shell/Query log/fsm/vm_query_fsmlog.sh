#!/bin/bash

#该脚本用户查询虚拟机fsm的日志freeswitch.log
#实时日志查询格式bash vm_query_fsmlog.sh 号码
#归档日志查询格式bash vm_query_fsmlog.sh 号码 2024-01-04


# 获取变量1（号码）和变量2（时间）
number="$1"
timestamp="$2"

# 使用ansible查询日志
if [ -z "$timestamp" ]; then
    # 如果没有提供时间参数，则执行实时日志查询
    ansible -i ~/hosts/hosts_all fsm -m shell -a "zgrep -h '$number' /data/ucp/ipcc/logs/media/fsm/freeswitch.log"
else
    # 如果提供了时间参数，则执行归档日志查询
    ansible -i ~/hosts/hosts_all fsm -m shell -a "zgrep -h '$number' /data/ucp/ipcc/ipcc_logs/media/fsm/freeswitch.log.$timestamp*"
fi

