#!/bin/bash
local_ip=$( (/usr/sbin/ip a | grep inet | grep team2 || /usr/sbin/ip a | grep inet | grep team1 || /usr/sbin/ip a | grep inet | grep bond0 || /usr/sbin/ip a | grep inet | grep eth0 | grep -v secondary) | grep brd | awk -F'/' '{print $1}' | awk '{print $NF}' | sort -u)
if [[ ${local_ip} =~ "192.168." ]]; then
	room=洛阳备中心
else
	room=淮安主中心
fi

alt_num=$(sh /home/ucp/shell/query-table-space.sh)
echo "通信云黑龙江${room}监控CDS ${local_ip}主机altibase表空间使用量|${alt_num}|int"
