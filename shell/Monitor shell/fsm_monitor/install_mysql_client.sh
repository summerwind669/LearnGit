#!/bin/bash
#该脚本是在fsm主机安装的mysql client
# 检查是否存在安装文件
if [ ! -f /home/ucp/app-share/mysql8.0.35_setup.tar.gz ]; then
    echo "Error: mysql8.0.35_setup.tar.gz file not found!"
    exit 1
fi

# 解压文件到 /home/ucp/app-share/
tar -xzvf /home/ucp/app-share/mysql8.0.35_setup.tar.gz -C /home/ucp/app-share/

# 安装 RPM 包
rpm -ivh /home/ucp/app-share/mysql8.0.35_setup/mysql-community-client-plugins-8.0.35-1.el8.x86_64.rpm && \
rpm -ivh /home/ucp/app-share/mysql8.0.35_setup/mysql-community-common-8.0.35-1.el8.x86_64.rpm && \
rpm -ivh /home/ucp/app-share/mysql8.0.35_setup/mysql-community-libs-8.0.35-1.el8.x86_64.rpm && \
rpm -ivh /home/ucp/app-share/mysql8.0.35_setup/mysql-community-client-8.0.35-1.el8.x86_64.rpm && \


# 检查是否所有 RPM 包都已成功安装
if [ $? -eq 0 ]; then
    echo "MySQL 8.0.35 client has been installed successfully!"
else
    echo "Error: Installation failed!"
    exit 1
fi