#!/bin/bash

# 设置Tomcat日志根目录
log_root="/data/ivrInterface"

# 设置Tomcat目录数组
tomcat_dirs=("tomcat1" "tomcat2" "tomcat3" "tomcat4")

# 获取昨天的日期
yesterday=$(date -d "yesterday" "+%Y-%m-%d")

# 循环处理每个Tomcat日志目录
for tomcat_dir in "${tomcat_dirs[@]}"; do
    # 构建昨天日志文件的完整路径
    log_file="${log_root}/${tomcat_dir}/logs/catalina.out.${yesterday}"

    # 检查文件是否存在
    if [ -f "$log_file" ]; then
        # 压缩日志文件为.gz格式
        gzip "$log_file"
        echo "压缩 $log_file 为 $log_file.gz"
    else
        echo "未找到 $log_file"
    fi
done
