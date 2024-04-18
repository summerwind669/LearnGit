#/bin/bash

function check_processes_and_ports {
    echo "===== 正在执行进程和端口巡检 ====="

    # Define modules with their IP addresses
    declare -A modules=(
        ["dm"]="10.119.62.74 10.119.62.75 10.119.62.76 10.119.62.77"
        ["crs"]="10.119.62.78 10.119.62.79 10.137.78.58 10.137.78.59"
        ["flume"]="10.119.62.80 10.137.78.60"
    )

    for module in "${!modules[@]}"; do
        # Get IP addresses for the current module
        ips="${modules[$module]}"

        # Split IP addresses by space
        IFS=' ' read -ra ip_list <<< "$ips"

        # Connect to each IP address in the current module
        for ip in "${ip_list[@]}"; do
            # Check processes on the current host
            echo "正在检查 $module 模块的 $ip 的进程和端口..."
            ssh -q $ip "
                if [[ \"$module\" == \"dm\" ]]; then
                    if pgrep -f \"/home/ucp/dm/node1/bin/dm.jar\" > /dev/null && pgrep -f \"/home/ucp/dm/node2/bin/dm.jar\" > /dev/null; then
                        echo -e \"\e[1;32mDM 进程正常\e[0m\"
                    else
                        echo -e \"\e[1;31mDM 进程异常\e[0m\"
                    fi

                    if netstat -tuln | grep ":18081" | grep -w "LISTEN" > /dev/null; then
                        echo -e \"\e[1;32mDM 18081端口正常\e[0m\"
                    else
                        echo -e \"\e[1;31mDM 18081端口异常\e[0m\"
                    fi

                    if netstat -tuln | grep ":18082" | grep -w "LISTEN" > /dev/null; then
                        echo -e \"\e[1;32mDM 18082端口正常\e[0m\"
                    else
                        echo -e \"\e[1;31mDM 18082端口异常\e[0m\"
                    fi
                fi

                if [[ \"$module\" == \"crs\" ]]; then
                    if pgrep -f \"/home/ucp/crs/node1/bin/crs.jar\" > /dev/null; then
                        echo -e \"\e[1;32mCRS 进程正常\e[0m\"
                    else
                        echo -e \"\e[1;31mCRS 进程异常\e[0m\"
                    fi

                    if netstat -tuln | grep ":18080" | grep -w "LISTEN" > /dev/null; then
                        echo -e \"\e[1;32mCRS 18080端口正常\e[0m\"
                    else
                        echo -e \"\e[1;31mCRS 18080端口异常\e[0m\"
                    fi
                fi

                if [[ \"$module\" == \"flume\" ]]; then
                    if pgrep -f \"/home/ucp/flume_khd/flume\" > /dev/null; then
                        echo -e \"\e[1;32mFlume 进程正常\e[0m\"
                    else
                        echo -e \"\e[1;31mFlume 进程异常\e[0m\"
                    fi

                    if netstat -tuln | grep ":4545" | grep -w "LISTEN" > /dev/null; then
                        echo -e \"\e[1;32mFlume 4545端口正常\e[0m\"
                    else
                        echo -e \"\e[1;31mFlume 4545端口异常\e[0m\"
                    fi
                fi
            "
        done
    done
}


check_processes_and_ports
