#!/bin/bash

# Ŀ������ IP ��������
TARGET="B_HOST_IP_OR_NAME"

# ����ļ�·��
OUTPUT_FILE="ping_result.log"

# ��ʼ ping Ŀ������
while true
do
    # ��ȡ��ǰʱ��
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

    # ִ�� ping ����ȡ���
    PING_RESULT=$(ping -c 1 $TARGET)

    # ��ʱ����� ping ���д������ļ�
    echo "[$TIMESTAMP] $PING_RESULT" >> $OUTPUT_FILE

    # ���һ���ӳ٣�����Ƶ�� ping�����磺ÿ 1 �� ping һ�Σ�
    sleep 1
done
