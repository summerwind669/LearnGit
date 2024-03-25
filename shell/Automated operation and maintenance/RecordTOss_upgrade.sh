#!/bin/bash

# 定义远程主机用户名
REMOTE_USER="username"

# 获取需要升级的主机列表
get_hosts() {
    ansible -i ~/hosts/hosts_all record --list-hosts
}

# 检查主机架构并执行升级操作
upgrade_host() {
    local host="$1"
    
    # 检查目标主机的操作系统架构
    local arch=$(ssh "$REMOTE_USER@$host" uname -m)
    
    # 如果是 x86_64 架构
    if [[ "$arch" == "x86_64" ]]; then
        echo "Copying and extracting x86 package on $host"
        scp recordtoss-v1.0.6-Release-20231220_x86.tar.gz "$REMOTE_USER@$host:/tmp/"
        ssh "$REMOTE_USER@$host" "tar -xzvf /tmp/recordtoss-v1.0.6-Release-20231220_x86.tar.gz -C /tmp/"
    # 如果是 ARM 架构
    elif [[ "$arch" == "arm"* || "$arch" == "aarch64" ]]; then
        echo "Copying and extracting ARM package on $host"
        scp recordtoss-v1.0.6-Release-20231220_arm.tar.gz "$REMOTE_USER@$host:/tmp/"
        ssh "$REMOTE_USER@$host" "tar -xzvf /tmp/recordtoss-v1.0.6-Release-20231220_arm.tar.gz -C /tmp/"
    else
        echo "Unsupported architecture on $host: $arch"
        return 1
    fi
    
    # 拷贝recordtoss文件到目标目录
    ssh "$REMOTE_USER@$host" "cp /tmp/bin/recordtoss ~/RecordTOss/bin/"
    
    # 如果~/RecordTOss_znwh目录存在，则拷贝recordtoss到~/RecordTOss_znwh/bin下
    if ssh "$REMOTE_USER@$host" "[ -d ~/RecordTOss_znwh ]"; then
        echo "Copying and extracting x86 package on $host for RecordTOss_znwh"
        ssh "$REMOTE_USER@$host" "cp /tmp/bin/recordtoss ~/RecordTOss_znwh/bin/"
        ssh "$REMOTE_USER@$host" "~/RecordTOss_znwh/bin/bash recordtoss.sh stop"
    fi
    
    # 停止服务
    ssh "$REMOTE_USER@$host" "~/RecordTOss/bin/bash recordtoss.sh stop"
}

# 检查服务是否启动并输出启动时间
check_service() {
    local host="$1"
    
    # 检查服务是否启动
    local start_time=$(ssh "$REMOTE_USER@$host" "ps -eo pid,lstart,cmd | grep recordtoss | grep -v grep | awk '{print \$2}'")
    
    if [ -n "$start_time" ]; then
        echo "RecordTOss service is running on $host. Started at: $start_time"
    else
        echo "RecordTOss service is not running on $host"
    fi
}

# 主函数，遍历所有主机并执行升级操作
main() {
    local hosts=$(get_hosts)
    
    for host in $hosts
    do
        echo "Processing host: $host"
        upgrade_host "$host"
        check_service "$host"
        echo "========================================="
    done
}

# 执行主函数
main
