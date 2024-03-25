#!/bin/bash

# 定义远程主机用户名
REMOTE_USER="username"

# 复制和解压安装包
copy_and_extract_package() {
    local host="$1"
    local package="$2"
    
    scp "$package" "$REMOTE_USER@$host:/tmp/"
    ssh "$REMOTE_USER@$host" "tar -xzvf /tmp/$(basename "$package") -C /tmp/"
}

# 复制recordtoss文件到指定目录
copy_recordtoss_to_directory() {
    local host="$1"
    local directory="$2"
    
    ssh "$REMOTE_USER@$host" "cp /tmp/bin/recordtoss $directory"
}

# 停止服务
stop_service() {
    local host="$1"
    local service_path="$2"
    
    ssh "$REMOTE_USER@$host" "$service_path/bash recordtoss.sh stop"
}

# 检查服务是否停止
check_service_stopped() {
    local host="$1"
    
    ssh "$REMOTE_USER@$host" "ps aux | grep recordtoss | grep -v grep"
    if [ $? -eq 0 ]; then
        echo "Failed to stop RecordTOss service on $host"
    else
        echo "RecordTOss service stopped successfully on $host"
    fi
}

# 检查日志文件路径
check_log_path() {
    local host="$1"
    local log_path="$2"
    
    ssh "$REMOTE_USER@$host" "ls $log_path/RecordTOss.log"
    if [ $? -eq 0 ]; then
        echo "RecordTOss log found on $host"
    else
        echo "RecordTOss log not found on $host"
    fi
}

# 主函数，处理升级操作
main() {
    # 使用 Ansible 获取需要升级的主机列表
    local hosts=$(ansible -i ~/hosts/hosts_all record --list-hosts)
    
    for host in $hosts
    do
        # 检查目标主机的操作系统架构
        local arch=$(ssh "$REMOTE_USER@$host" uname -m)
        
        # 根据架构选择安装包
        local package
        if [[ "$arch" == "x86_64" ]]; then
            package="recordtoss-v1.0.6-Release-20231220_x86.tar.gz"
        elif [[ "$arch" == "arm"* || "$arch" == "aarch64" ]]; then
            package="recordtoss-v1.0.6-Release-20231220_arm.tar.gz"
        else
            echo "Unsupported architecture on $host: $arch"
            continue
        fi
        
        # 复制和解压安装包
        copy_and_extract_package "$host" "$package"
        
        # 拷贝recordtoss文件到目标目录
        copy_recordtoss_to_directory "$host" "~/RecordTOss/bin/"
        
        # 如果~/RecordTOss_znwh目录存在，则拷贝recordtoss到~/RecordTOss_znwh/bin下
        if ssh "$REMOTE_USER@$host" "[ -d ~/RecordTOss_znwh ]"; then
            copy_recordtoss_to_directory "$host" "~/RecordTOss_znwh/bin/"
            stop_service "$host" "~/RecordTOss_znwh"
        fi
        
        # 停止服务
        stop_service "$host" "~/RecordTOss"
        
        # 检查服务是否停止
        check_service_stopped "$host"
        
        # 检查日志文件路径
        check_log_path "$host" "~/RecordTOss/logs"
        
        # 如果存在~/RecordTOss_znwh/logs目录，则检查日志文件路径
        check_log_path "$host" "~/RecordTOss_znwh/logs"
    done
}

# 执行主函数
main
