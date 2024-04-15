#!/bin/bash
#该脚本用户查询统一调度的日志zucService*.log
#实时日志查询格式bash query_zucServicelog.sh number
#归档日志查询格式bash query_zucServicelog.sh number timestamp
#归档日志时间格式yyyy-mm-dd-hh


# 变量1（号码）、变量2（时间）

number="$1"
timestamp="$2"


# 判断查询实时日志还是归档日志
if [ -z "$timestamp" ]; then
    # 如果没有提供时间参数，则执行实时日志查询
    ansible -i ~/hosts/hosts_wh zuc_ly:zuc_ha -m shell -a "zgrep -h '$number' /home/ucp/zuc/zcu*/zuc-ucp-service/logs/zucService_*.log"
else
    # 如果提供了时间参数，则执行归档日志查询
    # 检查变量2是否合法（使用正则表达式匹配日期格式）
    if ! [[ $timestamp =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Error: Invalid date format. Use 'yyyy-mm-dd-hh'."
        exit 1
    fi
    ansible -i ~/hosts/hosts_wh zuc_ly:zuc_ha -m shell -a "zgrep -h '$number' /home/ucp/zuc/zcu*/zuc-ucp-service/logs/zucService_*$timestamp*"
fi
