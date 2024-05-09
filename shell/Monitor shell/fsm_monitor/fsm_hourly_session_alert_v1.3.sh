#!/bin/bash

# 数据库连接信息
db_host="10.119.62.10"
db_name="fsm_data"
db_user="txy_monitor_fsm"
db_password="txy_monitor_fsm"
mysql_client="/home/monitor/mysql_client/mysql"

# 获取当前时间的半小时之前的时间
CURRENT_HOUR=$(date +"%Y-%m-%d %H:%M:%S")
CURRENT_HALF_HOUR=$(date -d "30 minutes ago" +"%Y-%m-%d %H:%M:%S")

# 检查当前时间是否在不发出告警的时间段内（20:00 到次日 08:30）
now_timestamp=$(date +%s)
alarm_starttime=$(date -d "08:30" +%s)
alarm_endtime=$(date -d "20:00" +%s)

if [ $now_timestamp -ge $alarm_starttime -a $now_timestamp -le $alarm_endtime ]; then
    # 查询半小时内每个媒体节点的current_session平均值
    QUERY="SELECT province, data_center, host_ip, ROUND(AVG(current_session), 2) AS avg_current_session FROM fsm_session_data_1min WHERE insert_time >= '$CURRENT_HALF_HOUR' AND insert_time < '$CURRENT_HOUR' GROUP BY province, data_center, host_ip"
    RESULT=$($mysql_client -h "$db_host" -u "$db_user" -p"$db_password" -D "$db_name" -s -N -e "$QUERY")

    # 计算该半小时全部媒体节点平均值
    TOTAL_AVG_QUERY="SELECT ROUND(AVG(current_session), 2) FROM fsm_session_data_1min WHERE insert_time >= '$CURRENT_HALF_HOUR' AND insert_time < '$CURRENT_HOUR'"
    TOTAL_AVG=$($mysql_client -h "$db_host" -u "$db_user" -p"$db_password" -D "$db_name" -s -N -e "$TOTAL_AVG_QUERY")

    # 发出告警
    while read -r line; do
        province=$(echo "$line" | awk '{ print $1 }')
        data_center=$(echo "$line" | awk '{ print $2 }')
        host_ip=$(echo "$line" | awk '{ print $3 }')
        avg_current_session=$(echo "$line" | awk '{ print $4 }')
        threshold=$(echo "scale=2; $TOTAL_AVG * 0.7" | bc)
        current_minimum_node_session_percent=$(awk 'BEGIN{printf "%.1f\n",('$avg_current_session'/'$TOTAL_AVG')*100}')

        if (( $(echo "$avg_current_session < $threshold" | bc -l) )); then
            echo "通信云$province$data_center, Host IP: $host_ip - 从 $CURRENT_HALF_HOUR 到 $CURRENT_HOUR 期间并发量平均值 ($avg_current_session) 小于全部节点平均值($TOTAL_AVG) 的70%，当前值(${current_minimum_node_session_percent}%)，请检查服务是否正常。|1|init"
            # 这里可以添加发送告警的逻辑，比如通过邮件、短信接口等方式
        fi
    done <<< "$RESULT"
else
    echo "当前时间处于不发出告警的时间段内（20:00 到次日 08:30），不发出告警。"
fi
