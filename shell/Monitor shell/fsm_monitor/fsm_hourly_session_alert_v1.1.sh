#!/bin/bash

# 数据库连接信息
db_host="10.119.62.10"
db_name="fsm_data"
db_user="txy_monitor_fsm"
db_password="txy_monitor_fsm"
mysql_client="/home/monitor/mysql_client/mysql"

# 获取当前时间
CURRENT_DATE=$(date +"%Y-%m-%d")
CURRENT_HOUR=$(date +"%H")

# 查询每小时每个媒体节点的current_session平均值
QUERY="SELECT province, data_center, host_ip, AVG(current_session) AS avg_current_session FROM fsm_session_data_1min WHERE DATE(insert_time) = '$CURRENT_DATE' AND HOUR(insert_time) = '$CURRENT_HOUR' GROUP BY province, data_center, host_ip"
RESULT=$(mysql -h "$db_host" -u "$db_user" -p"$db_password" -D "$db_name" -s -N -e "$QUERY")

# 计算该小时全部媒体节点平均值
TOTAL_AVG_QUERY="SELECT AVG(current_session) FROM fsm_session_data_1min WHERE DATE(insert_time) = '$CURRENT_DATE' AND HOUR(insert_time) = '$CURRENT_HOUR'"
TOTAL_AVG=$(mysql -h "$db_host" -u "$db_user" -p"$db_password" -D "$db_name" -s -N -e "$TOTAL_AVG_QUERY")

# 发出告警
while read -r line; do
    province=$(echo "$line" | awk '{ print $1 }')
    data_center=$(echo "$line" | awk '{ print $2 }')
    host_ip=$(echo "$line" | awk '{ print $3 }')
    avg_current_session=$(echo "$line" | awk '{ print $4 }')
    threshold=$(echo "scale=2; $TOTAL_AVG * 0.98" | bc)
    
    if (( $(echo "$avg_current_session < $threshold" | bc -l) )); then
        echo "$province$data_center, Host IP: $host_ip - 从 $CURRENT_HOUR 点开始一个小时并发量平均值 ($avg_current_session) 小于全部节点平均值($TOTAL_AVG) 的98%，请检查服务是否正常。"
        # 这里可以添加发送告警的逻辑，比如通过邮件、短信接口等方式
    fi
done <<< "$RESULT"
