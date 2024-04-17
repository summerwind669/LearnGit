#!/bin/bash

# 巡检系统性能
function check_performance {
    echo "===== 正在执行系统性能巡检 ====="
    echo "CPU、内存、磁盘使用情况："

    # 使用 Ansible 执行命令获取系统性能信息
    ansible -i /home/ucp/hosts/hosts_all all -m shell -a "top -bn1 | grep 'Cpu(s)\|Mem'; df -h /home /data" | while read -r line; do
        host=$(echo "$line" | awk '{print $1}')
        cpu_usage=$(echo "$line" | awk '{print $2}')
        mem_usage=$(echo "$line" | awk '{print $4}')
        disk_usage=$(echo "$line" | awk '{print $6}')

        if (( $(echo "$cpu_usage > 50" | bc -l) )); then
            echo -e "\e[1;33m$host CPU 利用率超过 50%：$cpu_usage%\e[0m"
        fi

        if (( $(echo "$mem_usage > 80" | bc -l) )); then
            echo -e "\e[1;31m$host 内存利用率超过 80%：$mem_usage%\e[0m"
        fi

        if (( $(echo "$disk_usage > 85" | bc -l) )); then
            echo -e "\e[1;31m$host $disk_usage 磁盘利用率超过 85%：$disk_usage%\e[0m"
        fi
    done
}

# 巡检进程和端口
function check_processes_and_ports {
    echo "===== 正在执行进程和端口巡检 ====="

    # 使用 Ansible 执行命令检查进程和端口
    ansible -i /home/ucp/hosts/hosts_all all -m shell -a "pgrep -f '/home/ucp/dm/node1/bin/dm.jar' > /dev/null; pgrep -f '/home/ucp/dm/node2/bin/dm.jar' > /dev/null; netstat -tuln | grep ':18081' > /dev/null; netstat -tuln | grep ':18082' > /dev/null; pgrep -f '/home/ucp/crs/node1/bin/crs.jar' > /dev/null; netstat -tuln | grep ':18180' > /dev/null; pgrep -f '/home/ucp/flume_khd/flume' > /dev/null; netstat -tuln | grep ':4545' > /dev/null" | while read -r line; do
        host=$(echo "$line" | awk '{print $1}')
        process=$(echo "$line" | awk '{print $3}')

        if [[ "$process" =~ "dm.jar" ]]; then
            if [[ "$process" =~ "18081" ]]; then
                echo -e "\e[1;32m$host DM 进程 node1 存在\e[0m"
            elif [[ "$process" =~ "18082" ]]; then
                echo -e "\e[1;32m$host DM 进程 node2 存在\e[0m"
            else
                echo -e "\e[1;31m$host DM 进程 $process 不存在\e[0m"
            fi
        elif [[ "$process" =~ "crs.jar" ]]; then
            echo -e "\e[1;32m$host CRS 进程存在\e[0m"
        elif [[ "$process" =~ "flume" ]]; then
            echo -e "\e[1;32m$host Flume 进程存在\e[0m"
        fi
    done
}

# 巡检服务日志
function check_service_logs {
    echo "===== 正在执行服务日志巡检 ====="

    # 使用 Ansible 执行命令检查服务日志
    ansible -i /home/ucp/hosts/hosts_all all -m shell -a "grep -E 'OutOfMemoryError|ESError|NLU请求失败|getCallBack方法调用的HTTP请求异常|ivrInterface请求失败|写入 redis异常|同步更新出错|异步更新出错|替换短信模板的内容，读取ES配置出错|未读取到redis内存储的提示音|获取短信名称和内容，读取ES配置出错|读取redis缓存失败|flume发送消息出错|incallInfo消息写入es出错|incallInfo消息放入ES incallInfoQueue出错|incallInfo消息放入flume queue出错|incommuInfo消息写入es出错|incommuInfo消息放入ES incallInfoQueue出错|incommuInfo消息放入flume queue出错|provincecode has no robotid in redis|provincecode info format is wrong|replay列表为空且action为空|上传文件异常|写入 redis异常|删除redis中当前会话数据异常|刷新出错|同步更新出错|定时任务uploadONest报错|将执行兜底流程，异常原因：action不匹配|文件写入异常|读取redis缓存失败|调用DM-对话管理模块异常|调用http接口出错|调用http接口请求NLU出错' /path/to/your/log/file" | while read -r line; do
        host=$(echo "$line" | awk '{print $1}')
        log_message=$(echo "$line" | awk '{$1=""; print $0}')

        if [[ -n "$log_message" ]]; then
            echo -e "\e[1;31m$host 日志中存在异常：$log_message\e[0m"
        else
            echo -e "\e[1;32m$host 日志刷新正常\e[0m"
        fi
    done
}

# 调用函数执行巡检
check_performance
check_processes_and_ports
check_service_logs
