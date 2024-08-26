#!/bin/bash

# ��ȡ��ǰʱ���
current_time=$(date +"%m-%d %H:%M:%S")

# ���������ǰ��ʱ���
start_time=$(date -d "-5 minutes" +"%m-%d %H:%M:%S")

# ��ȡ��־�ļ�·��
log_file="/data/ucp/ipcc/logs/scc/LB/SimpleConn.log"

# ʹ�� grep ���˳�ʱ�䷶Χ�ڵ���־�����ֱ�ͳ�� Evt_IContact �� Cmd_IContact �ĳ��ִ���
evt_count=$(grep -E "^\[$start_time.*$|^\[$current_time.*$" "$log_file" | grep -c "Evt_IContact")
cmd_count=$(grep -E "^\[$start_time.*$|^\[$current_time.*$" "$log_file" | grep -c "Cmd_IContact")

# ��ȡ��ǰ������ IP ��ַ
ip_address=$(hostname -i)

# �ж� IP ��ַǰ׺�������Ӧ����Ϣ
if [[ $ip_address == 192.* ]]; then
    echo "����IM LB���������������Ϊ��$evt_count"
elif [[ $ip_address == 172.* ]]; then
    echo "����IM LB���������������Ϊ��$cmd_count"
else
    echo "�޷�ʶ���������IP��ַ��$ip_address"
fi
