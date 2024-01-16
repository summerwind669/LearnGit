#!/bin/bash

#该脚本用户查询bicc信令的日志
#实时日志查询格式bash query_bicc_siflog.sh 号码
#归档日志查询格式bash query_bicc_siflog.sh 号码 20240104
#归档日志时间格式yyyymmdd

# 获取变量1（号码）和变量2（时间）
number="$1"
timestamp="$2"

# 使用ansible查询日志
if [ -z "$timestamp" ]; then
    # 如果没有提供时间参数，则执行实时日志查询
    ansible -i ~/hosts/hosts_all signal -m shell -a "zgrep -h '$number' /data/ucp/signal/scu*/log/sif*_sys.log"
else
    # 如果提供了时间参数，则执行归档日志查询
    ansible -i ~/hosts/hosts_all signal -m shell -a "zgrep -h '$number' /data/ucp/signal/scu*/log/sif*_sys_$timestamp*"
fi

