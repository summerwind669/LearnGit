#!/bin/bash
#该shell用于检查近4个小时话单文件大小小于2309字节的文件且文件中没有内容并输出文件路径
#如果是record备节点base_dir="/data/ucp/archive/archive"
#如果是record主节点base_dir="/data/ucp/archive/archive_bak"
#如果是中心话单备节点base_dir="/data/ucp/archive/archive"
#如果是中心话单主节点base_dir="/data/ucp/archive/archive_bak"

# 设置基础目录路径
base_dir="/data/ucp/archive/archive"

# 获取当前日期
current_year=$(date '+%Y')
current_month=$(date '+%m')
current_day=$(date '+%d')
current_date="$current_year-$current_month-$current_day"
current_hour=$(date '+%H')
# 获取当前小时和上一个小时
current_hour=$(date '+%H')
previous_hour=`date -d "1 hour ago" +"%H"`
#获取本机ip
local_ip=`hostname -i|awk '{print $1}'`


# 查找一小时内的文件
find_last_hour_files() {
    local platform_id=$1
    local bt_dir="$base_dir/$platform_id/BT/$current_year/$current_month/$current_day"

    if [ -d "$bt_dir" ]; then
        find "$bt_dir" -type f -name 'BT_*.zip' -mmin -120
    fi
}

# 查找小于2309字节的文件
find_small_files() {
    while IFS= read -r zip_file; do
        if [ -s "$zip_file" ] && [ "$(wc -c < "$zip_file")" -lt 2309 ]; then
            echo "$zip_file"
        fi
    done
}

# 检查文件内容是否包含当日日期
check_file_content() {
    local zip_file=$1
    # 获取zip文件中的内容
    content=$(unzip -p "$zip_file")

    # 检查内容是否包含当天日期
    if [[ $content == *"$current_date"* ]]; then
        echo "Content in $zip_file contains $current_date"
    else
	# 在这里可以输出文件名，也可以将文件名添加到一个数组中，以备后续统计
        empty_files+=("$zip_file")
        ((empty_files_count++))
    fi
}

# 列出所有platform_id目录
platform_ids=$(ls "$base_dir")

# 遍历每个平台platform_id目录
while IFS= read -r platform_id; do
    # 查找一小时内的文件
    last_hour_files=$(find_last_hour_files "$platform_id")

    # 查找小于2309字节的文件
    small_files=$(find_small_files <<< "$last_hour_files")

    # 再对小文件查找里面的内容是否包含当天日期，不包含日期说明文件为空
    if [ -n "$small_files" ]; then
        while IFS= read -r file; do
            check_file_content "$file"
        done <<< "$small_files"
    fi
done <<< "$platform_ids"

# 输出监控信息
if [ "$empty_files_count" -gt 0 ]; then
    echo "通信云青海省湟中机房$local_ip主机${previous_hour}-${current_hour}点两个小时存在空话单文件，请检查话单是否存在问题。|$empty_files_count|int"
fi