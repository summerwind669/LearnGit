#!/bin/bash
#该脚本用户查询统一调度的日志agentService.log
#实时日志查询格式bash query_agentServcielog.sh 号码
#归档日志查询格式bash query_agentServcielog.sh 号码 2024-01-04


# 获取变量1（sbc）、变量2（号码）、变量3（时间）
province="$1"
number="$2"
timestamp="$3"

# 检查变量1是否合法
case $province in
    "hl" | "jl" | "ln" | "bj" | "tj" | "he" | "qh" | "sx" | "sd" | "nm")
        # 合法值
        ;;
    *)
        echo "Error: Invalid value for variable1. Use 'hl', 'jl', 'ln', 'bj', 'tj', 'he','qh', 'sx', 'sd',or 'nm'."
        exit 1
        ;;
esac

# 判断查询实时日志还是归档日志
if [ -z "$timestamp" ]; then
    # 如果没有提供时间参数，则执行实时日志查询
    ansible -i ~/hosts/"$province" tydd -m shell -a "zgrep -h '$number' /home/ucp/agentService/tomcat*/logs/agentService_*.log"
else
    # 如果提供了时间参数，则执行归档日志查询
    # 检查变量3是否合法（使用正则表达式匹配日期格式）
    if ! [[ $timestamp =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Error: Invalid date format. Use 'yyyy-mm-dd-hh'."
        exit 1
    fi
    ansible -i ~/hosts/"$province" tydd -m shell -a "zgrep -h '$number' /home/ucp/agentService/tomcat*/logs/agentService_*$timestamp.log.gz"
fi
