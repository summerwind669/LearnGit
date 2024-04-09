#!/bin/bash

#############################################################################################################################
#1、运行脚本需要安装ffmpeg,欧拉系统源上有这个工具,可以直接yum安装,centos源没有这个工具,可以使用第3和第4步骤的绿色二进制文件          #
#2、脚本用法：bash check_mp4.sh 目录路径，比如bash check_mp4_v1.1.sh /data/ucp/record/upload ,请自行修改脚本中的year和month变量  #
#3、如果无法安装,请直接把126跳板机上的绿色二进制文件拷贝到record的/usr/bin下，赋权755，请自行解压126对应系统版本的压缩包             #
#4、126文件位置/home/ucp/founder下, ffmpeg-git-amd64-static.tar.xz是x86的， ffmpeg-git-amd64-static.tar.xz是arm的             #
# ###########################################################################################################################

# 检查参数是否传递
if [ -z "$1" ]; then
    echo "请输入要统计的目录路径"
    exit 1
fi

# 检查目录是否存在
if [ ! -d "$1" ]; then
    echo "目录不存在"
    exit 1
fi

# 定义目录路径
directory="$1"
year="2024"
month="03"

# 按月统计
for day in {01..31}; do
    # 构造日期目录路径
    day_directory="$directory/$year/$month/$day"
    
    # 检查日期目录是否存在
    if [ -d "$day_directory" ]; then
        echo "统计日期：$year/$month/$day"
        
        # 检查是否存在 /tmp/output$year$month.txt 文件，如果存在则删除
        output_file="/tmp/output$year$month.txt"
        if [ -f "$output_file" ]; then
            rm "$output_file"
        fi

        # 使用 find 命令递归地遍历日期目录下的所有 mp4 文件，并对每个文件执行 ffprobe 分析
        find "$day_directory" -type f \( -iname "*.mp4" -o -iname "*.MP4" \) -exec ffprobe {} \; >> "$output_file" 2>&1

        # 统计输出文件中包含 "Invalid data found" 的行数
        invalid_data_count=$(grep -c "Invalid data found" "$output_file")    
        
        # 统计检查的总 mp4 文件数量
        total_mp4_count=$(find "$day_directory" -type f \( -iname "*.mp4" -o -iname "*.MP4" \) | wc -l)
        
        # 打印统计结果
        if [ "$total_mp4_count" -ne 0 ]; then
            file_corruption_rate=$(echo "scale=3; $invalid_data_count / $total_mp4_count * 100" | bc | awk '{printf "%.3f", $0}')
            echo "$year/$month/$day： $total_mp4_count 个 mp4 文件, 文件损坏个数为: $invalid_data_count, 文件损坏率为: $file_corruption_rate%"
        else
            echo "$year/$month/$day： 没有找到任何 mp4 文件"
        fi
    fi
done
