#!/bin/bash
#其中local_count中使用两个中心备节点record，oss_count中使用主机部署有rclone程序即可
#需要把record的主机的monitor用户加到ucpsftp组中
#需要做cms跳板机monitor到record主机monitor的免密

# 获取当前小时
current_hour=$(date +"%H")

# 判断当前时间是否在 0 点到 1 点之间
if [ "$current_hour" -eq 00 ]; then
    # 当前是 0 点到 1 点，统计昨天 23 点的数据
    target_date=$(date -d "yesterday" +"%Y/%m/%d")
    target_prefix=$(date -d "yesterday" +"%Y%m%d")
    last_hour="23"
    start_time="$target_date 23点"
    end_time="$(date +"%Y/%m/%d") 00点"
else
    # 统计今天前一个小时的数据
    target_date=$(date +"%Y/%m/%d")
    target_prefix=$(date +"%Y%m%d")
    last_hour=$(date -d "1 hour ago" +"%H")
    start_time="$target_date $(date -d '1 hour ago' +'%H点')"
    end_time="$target_date $(date +'%H点')"
fi

# 构建录音文件名关键字
last_hour_prefix="${target_prefix}${last_hour}"

# 定义省份、本地主机列表和 OSS 配置信息、rclone程序路径
province='山西'
hosts_file="/home/ucp/hosts/hosts_all"
oss_config="/home/ucp/.config/rclone/ali-rclone.conf"
oss_bucket="ali-ceph:prd-tongxinyun-35110086-fx-rdo/35110086/upload/$target_date/"

# 统计本地数据文件数量并将结果相加
local_count=$(ansible -i $hosts_file 172.20.150.35:172.20.150.140 -m shell -a "cd /data/ucp/record/upload/$target_date && find ./ -type f -name '*$last_hour_prefix*mp[34]' | wc -l" | grep -E '^[0-9]+$' | awk '{s+=$1} END {print s}')

# 统计 OSS 上的文件数量
oss_count=$(ansible -i $hosts_file 172.20.150.35 -m shell -a "/home/ucp/rclone-v1.57.0/rclone --config $oss_config ls $oss_bucket --include '*$last_hour_prefix*.mp[34]' | wc -l" | tail -n 1)

# 输出结果
echo "通信云${province} RECORD 主机上个小时本地录音文件数量: |$local_count|int"
echo "通信云${province} OSS 桶上个小时上传的录音文件数量: |$oss_count|int"

# 输出$oss_count与$local_count的差值
count_diff=$((local_count - oss_count))

#输出告警结果
echo "通信云${province} 上个小时上传OSS桶的录音文件数少于RECORD本地录音文件${count_diff}个, 其中RECORD：${local_count}, OSS:${oss_count}，请检查是否异常。|${count_diff}|int"

