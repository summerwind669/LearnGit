#!/bin/bash
#该脚本用于查询5gisbc-signal,sip-proxy,isbc,asbc的信令日志ucp_proxy.log
#实时日志查询格式bash vm_query_11ivr_OpenVxilog.sh 号码
#归档日志查询格式bash vm_query_11ivr_OpenVxilog.sh 号码 2024010415


# 获取变量1（sbc）、变量2（号码）、变量3（时间）
sbc="$1"
number="$2"
timestamp="$3"

# 检查变量1是否合法
case $sbc in
    "5gisbc-signal" | "sip-proxy" | "isbc" | "asbc")
        # 合法值
        ;;
    *)
        echo "Error: Invalid value for variable1. Use '5gisbc-signal', 'sip-proxy', 'isbc', or 'asbc'."
        exit 1
        ;;
esac

# 检查变量3是否合法（使用正则表达式匹配日期格式）
if ! [[ $timestamp =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: Invalid date format. Use 'yyyy-mm-dd'."
    exit 1
fi

# 使用ansible查询日志
if [ -z "$timestamp" ]; then
    # 如果没有提供时间参数，则执行实时日志查询
    ansible -i ~/hosts/hosts_all "$sbc" -m shell -a "zgrep -h '$number' /data/ucp/fusionsbc/log/kamailio/ucp_proxy.log"
else
    # 如果提供了时间参数，则执行归档日志查询
    ansible -i ~/hosts/hosts_all "$sbc" -m shell -a "zgrep -h '$number' /data/ucp/fusionsbc/log/kamailio/ucp_proxy.log.$timestamp*"
fi
