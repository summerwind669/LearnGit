#!/bin/bash
#其中数据库为部署的数据库信息，请根据具体情况设置
source /home/monitor/.bash_profile

# 获取当前时间
current_time=$(date +"%Y-%m-%d %H:%M:%S")

# 获取主机名
hostname=$(hostname)

# 获取主机IP地址
host_ip=$(hostname -I | awk '{print $1}')

# 获取当前并发量
current_session=$(/home/ucp/ipcc/tools/fs_cli -P 8021 -x status | grep 'session(s) - peak' | awk '{print $1}')

# 数据库信息
db_host="10.119.62.10"
db_name="fsm_data"
db_user="txy_monitor_fsm"
db_password="txy_monitor_fsm"

# 构建 SQL 插入语句
insert_sql="INSERT INTO fsm_session_data_5min (hostname, host_ip, current_session) VALUES ('$hostname', '$host_ip', '$current_session')"

# 执行 SQL 插入语句
mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$insert_sql"

# 输出要插入的数据内容
echo "要插入的数据内容为：时间: $current_time 主机名: $hostname 主机IP地址: $host_ip 当前并发量: $current_session"