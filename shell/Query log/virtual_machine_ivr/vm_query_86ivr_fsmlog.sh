#!/bin/bash

#该脚本用户查询虚拟机86ivr的日志，ivr升级到3.4.3版本后86ivr日志为FSM.log
#实时日志查询格式bash vm_query_86ivr_fsmlog.sh 号码
#归档日志查询格式bash vm_query_86ivr_fsmlog.sh 号码 2024-01-04


# 获取变量1（号码）和变量2（时间）
number="$1"
timestamp="$2"

# 使用ansible查询日志
if [ -z "$timestamp" ]; then
    # 如果没有提供时间参数，则执行实时日志查询
    ansible -i ~/hosts/hosts_all 86ivr -m shell -a "zgrep -h '$number' /data/ucp/ipcc/logs/media/fsm/FSM.log"
else
    # 如果提供了时间参数，则执行归档日志查询
    ansible -i ~/hosts/hosts_all 86ivr -m shell -a "zgrep -h '$number' /data/ucp/ipcc/ipcc_logs/media/fsm/FSM.log.$timestamp*"
fi

