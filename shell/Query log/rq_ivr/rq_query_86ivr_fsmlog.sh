#!/bin/bash
#author:zyb
#O(∩_∩)O If you have questions please contact me
######################################################################
#脚本使用说明：                                                       # 
#查询未归档日志需输入变量1号码或是callid或是gcid，变量2为省份缩写        #
#查询归档日志需输入变量1，变量2为省份缩写，变量3为时间                   #
#1、查询未归档日志 bash rq_query_86ivr_fsmlog.sh 10086 hl              # 
#2、查询归档日志   bash rq_query_86ivr_fsmlog.sh 10086 hl 2023-11-29   # 
######################################################################


# 检查参数数量
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <phone_number> <log_location> [log_date]"
    exit 1
fi

# 提取参数
phone_number=$1
log_location=$2
log_date=$3

# 根据log_location设置日志路径前缀
case "$log_location" in
  "hl")
    log_prefix="hljx-prd-dualstack-4th-respool/hl-jx-86ivr"
    ;;
  "jl")
    log_prefix="jlsb-prd-dualstack-4th-respool/jl-sb-86ivr"
    ;;
  # 添加其他地区的映射
  "ln")
    log_prefix="lndd-prd-dualstack-4th-respool/ln-dd-86ivr"
    ;;
  "bj")
    log_prefix="bjwj-prd-dualstack-4th-respool/bj-wj-86ivr"
    ;;
  "tj")
    log_prefix="tjnk-prd-dualstack-4th-respool/tj-nk-86ivr"
    ;;
  "he")
    log_prefix="helf-prd-dualstack-4th-respool/he-lf-86ivr"
    ;;
  "qh")
    log_prefix="qhhz-prd-dualstack-4th-respool/qh-hz-86ivr"
    ;;
  "sx")
    log_prefix="sxty-prd-dualstack-4th-respool/sx-ty-86ivr"
    ;;
  "sd")
    log_prefix="sdgx7l-prd-dualstack-4th-respool/sd-7f-86ivr"
    ;;
  "nm")
    log_prefix="nmyx-prd-dualstack-4th-respool/nm-yx-86ivr"
    ;;
  *)
    echo "Invalid log_location. Supported values: hl, jl, ln, bj, tj, he, qh, sx, sd, nm"
    exit 1
    ;;
esac

# 构建日志路径
log_path="/productlog/$log_prefix/ipcc/logs/media/fsm"
archive_log_path="/productlog/$log_prefix/ipcc/ipcc_logs/media/fsm"

# 构建日志文件名
realtime_log="*FSM.log"
archive_log="*FSM.log.${log_date}*"

# 构建查询命令
if [ -z "$log_date" ]; then
    # 查询未归档日志
    command="zgrep $phone_number $log_path/$realtime_log"
else
    # 查询归档日志
    command="zgrep $phone_number $archive_log_path/$archive_log"
fi

# 执行查询命令
ansible -i ~/hosts/hosts_all rq_ivr -m shell -a "$command"
