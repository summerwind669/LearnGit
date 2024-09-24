#!/bin/bash
local_ip=$( (/usr/sbin/ip a | grep inet | grep team2 || /usr/sbin/ip a | grep inet | grep team1 || /usr/sbin/ip a | grep inet | grep bond0 || /usr/sbin/ip a | grep inet | grep eth0 | grep -v secondary) | grep brd | awk -F'/' '{print $1}' | awk '{print $NF}' | sort -u)
if [[ ${local_ip} =~ "192.168." ]]; then
	room=����������
else
	room=����������
fi

alt_num=$(sh /home/ucp/shell/query-table-space.sh)
echo "ͨ���ƺ�����${room}���CDS ${local_ip}����altibase��ռ�ʹ����|${alt_num}|int"
