#!/bin/bash

#脚本用法：bash check_mp4.sh 目录路径，比如bash check_mp4.sh /data/ucp/tmp/06 查询6号当天的

# 检查目录是否存在
if [ ! -d "$1" ]; then
    echo "目录不存在"
    exit 1
fi

# 检查是否存在 /tmp/output.txt 文件，如果存在则删除
output_file="/tmp/output.txt"
if [ -f "$output_file" ]; then
    del "$output_file"
fi

# 使用 find 命令递归地遍历目录及其子目录下的所有 mp4 文件，并对每个文件执行 ffprobe 分析
find "$1" -type f \( -iname "*.mp4" -o -iname "*.MP4" \) -exec ffprobe {} \; >> "$output_file" 2>&1

echo "所有文件的输出已保存到 $output_file"

# 统计输出文件中包含 "Invalid data found" 的行数
invalid_data_count=$(grep -c "Invalid data found" "$output_file")
echo "输出文件中包含 'Invalid data found' 的行数为: $invalid_data_count"

# 统计检查的总 mp4 文件数量
total_mp4_count=$(find "$1" -type f \( -iname "*.mp4" -o -iname "*.MP4" \) | wc -l)
echo "总共检查了 $total_mp4_count 个 mp4 文件"

# 计算 mp4 文件的损坏率
if [ "$total_mp4_count" -ne 0 ]; then
    file_corruption_rate=$(echo "scale=2; $invalid_data_count / $total_mp4_count * 100" | bc)
    echo "mp4 文件的文件损坏率为: $file_corruption_rate%"
else
    echo "没有找到任何 mp4 文件"
fi
