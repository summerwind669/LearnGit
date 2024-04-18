#!/bin/bash

# 巡检服务日志
function check_service_logs {
    echo "===== 正在执行服务日志巡检 ====="

    # Define hosts with their IP addresses
    declare -A hosts=(
        ["dm"]="10.119.62.74 10.119.62.75 10.119.62.76 10.119.62.77"
        ["crs"]="10.119.62.78 10.119.62.79 10.137.78.58 10.137.78.59"
        ["flume"]="10.119.62.80 10.137.78.60"
    )

    for module in "${!hosts[@]}"; do
        ips="${hosts[$module]}"
        for ip in $ips; do
            echo "正在检查 $module 模块的 $ip 的日志..."
            case $module in
                "dm")
                    log_file="/home/ucp/dm/node*/logs/dm-$(ssh -q $ip hostname).log"
                    ;;
                "crs")
                    log_file="/home/ucp/crs/node*/logs/crs-$(ssh -q $ip hostname).log"
                    ;;
                "flume")
                    log_file="/home/ucp/flume_khd/flume/logs/flume.log"
                    ;;
                *)
                    echo "未知的模块：$module"
                    continue
                    ;;
            esac

            # 远程命令的输出
            result=$(ssh -q $ip "grep -E 'OutOfMemoryError|ESError|NLU请求失败|getCallBack方法调用的HTTP请求异常|ivrInterface请求失败|写入 redis异常|同步更新出错|异步更新出错|替换短信模板的内容，读取ES配置出错|未读取到redis内存储的提示音|获取短信名称和内容，读取ES配置出错|读取redis缓存失败' $log_file")
            
            # 检查结果是否为空
            if [ -n "$result" ]; then
                # 如果匹配到关键字，打印日志异常
                echo -e "\e[1;31m$module 模块 $ip 日志异常：$result\e[0m"
            else
                # 如果未匹配到关键字，打印日志正常
                echo -e "\e[1;32m$module 模块 $ip 日志正常\e[0m"
            fi
        done
    done
}

check_service_logs
